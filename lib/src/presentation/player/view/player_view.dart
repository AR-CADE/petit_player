import 'dart:async' show Future, StreamController;

import 'package:flutter/material.dart'
    show
        AspectRatio,
        BuildContext,
        Center,
        ClipRect,
        SizedBox,
        State,
        StatefulWidget,
        Widget;
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocBuilder, BlocListener, ReadContext;
import 'package:petit_player/petit_player.dart' show VideoLoadingStyle;
import 'package:petit_player/src/core/style/loader.dart' show Loader;
import 'package:petit_player/src/presentation/player/player.dart'
    show
        PlayerBloc,
        PlayerCreate,
        PlayerInitialized,
        PlayerLoading,
        PlayerState;
import 'package:video_player/video_player.dart'
    show VideoPlayer, VideoPlayerController;

class PlayerView extends StatefulWidget {
  const PlayerView({
    required this.uri,
    super.key,
    this.videoLoadingStyle,
    this.streamController,
    this.autoPlay = true,
    this.aspectRation,
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

  /// Aspect Ratio
  final double? aspectRation;

  @override
  PlayerViewState createState() => PlayerViewState();
}

class PlayerViewState extends State<PlayerView> {
  @override
  void initState() {
    super.initState();
    _loadUri(widget.uri);
  }

  @override
  void didUpdateWidget(covariant PlayerView oldWidget) {
    if (oldWidget.uri != widget.uri) {
      _loadUri(widget.uri);
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
          final loading = widget.videoLoadingStyle?.loading;
          return switch (state) {
            PlayerLoading() => Center(
                child: loading ?? const Loader(),
              ),
            PlayerInitialized() => ClipRect(
                child: SizedBox.expand(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: widget.aspectRation ??
                          (state.controller.value.aspectRatio == 1.0
                              ? 16 / 9
                              : state.controller.value.aspectRatio),
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

  void _loadUri(Uri uri) {
    _tryNotifyController(null);
    final minLoadingDuration = widget.videoLoadingStyle?.minDuration;
    context.read<PlayerBloc>().add(
          PlayerCreate(
            uri: uri,
            minLoadingDuration: minLoadingDuration ?? Duration.zero,
            httpHeaders: widget.httpHeaders,
          ),
        );
  }
}
