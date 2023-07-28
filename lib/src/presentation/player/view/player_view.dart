import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petit_player/petit_player.dart';
import 'package:petit_player/src/core/style/loader.dart';
import 'package:petit_player/src/presentation/player/player.dart';
import 'package:video_player/video_player.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    required this.uri,
    super.key,
    this.videoLoadingStyle,
    this.streamController,
    this.autoPlay = true,
    this.aspectRation = 16 / 9,
    this.httpHeaders = const <String, String>{},
  });

  /// Video source
  final Uri uri;

  /// Video Loading Style
  final VideoLoadingStyle? videoLoadingStyle;

  /// A Stream Controller of VideoPlayerController
  final StreamController<VideoPlayerController?>? streamController;

  /// Auto Play on init
  final bool autoPlay;

  /// HttpHeaders for network VideoPlayerController
  final Map<String, String> httpHeaders;

  /// Aspect Ration
  final double? aspectRation;

  @override
  PlayerViewState createState() => PlayerViewState();
}

class PlayerViewState extends State<PlayerView> {
  @override
  void initState() {
    super.initState();
    loadUrl(widget.uri);
  }

  @override
  void didUpdateWidget(covariant PlayerView oldWidget) {
    if (oldWidget.uri != widget.uri) {
      loadUrl(widget.uri);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    Future.microtask(() {
      if (!mounted) {
        return;
      }
      _tryNotifyController(null);
    });

    super.dispose();
  }

  void _tryNotifyController(VideoPlayerController? controller) {
    final streamController = widget.streamController;
    if (streamController != null && streamController.isClosed == false) {
      streamController.add(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
      listener: (context, state) {
        switch (state) {
          case PlayerInitialized():
            {
              _tryNotifyController(state.controller);

              if (widget.autoPlay) {
                state.controller.play();
              }
              break;
            }
          case PlayerLoading():
            break;
        }
      },
      child: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          final aspectRation = widget.aspectRation;
          return switch (state) {
            PlayerLoading() => Center(
                child: widget.videoLoadingStyle != null
                    ? widget.videoLoadingStyle?.loading
                    : const Loader(),
              ),
            PlayerInitialized() => ClipRect(
                child: SizedBox.expand(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio:
                          aspectRation ?? state.controller.value.aspectRatio,
                      child: VideoPlayer(state.controller),
                    ),
                  ),
                ),
              ),
          };
        },
      ),
    );
  }

  void loadUrl(Uri uri) {
    _tryNotifyController(null);
    context.read<PlayerBloc>().add(PlayerCreate(uri: uri));
  }
}
