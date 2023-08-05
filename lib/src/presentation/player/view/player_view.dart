import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:petit_player/petit_player.dart';
import 'package:petit_player/src/core/style/loader.dart';
import 'package:petit_player/src/presentation/player/widgets/center_aspect_ratio.dart';
import 'package:video_player/video_player.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    required this.uri,
    super.key,
    this.videoLoadingStyle,
    this.streamController,
    this.autoPlay = true,
    this.aspectRation,
    this.keepAspectRatio = true,
    this.httpHeaders = const <String, String>{},
    this.engine = PlayerEngine.native,
  });

  /// Player engine (curently supported : 'native (default)', 'mediaKit')
  final PlayerEngine engine;

  /// Video source
  final Uri uri;

  /// Video Loading Style
  final VideoLoadingStyle? videoLoadingStyle;

  /// A Stream Controller of VideoPlayerController
  final StreamController<PlayerState?>? streamController;

  /// Auto Play on init
  final bool autoPlay;

  /// HttpHeaders for network VideoPlayerController
  final Map<String, String> httpHeaders;

  /// Aspect Ratio
  final double? aspectRation;

  /// Keep Aspect Ratio,
  /// NOTE : if `aspectRation` is set, `keepAspectRatio` will be set to true
  final bool keepAspectRatio;

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

  void _tryNotifyController(PlayerState? state) {
    final streamController = widget.streamController;
    if (streamController != null && streamController.isClosed == false) {
      streamController.add(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
      listener: (context, state) async {
        switch (state) {
          case PlayerNativeInitialized():
            {
              _tryNotifyController(state);
              break;
            }
          case PlayerMediaKitInitialized():
            {
              _tryNotifyController(state);
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
            PlayerNativeInitialized() => ClipRect(
                child: SizedBox.expand(
                  child: Builder(
                    builder: (context) {
                      return switch ((widget.aspectRation != null) ||
                          widget.keepAspectRatio) {
                        true => CenterAspectRatio(
                            aspectRatio: _calculateNativeAspectRatio(state),
                            child: VideoPlayer(state.controller),
                          ),
                        false => ColoredBox(
                            color: Colors.black,
                            child: VideoPlayer(state.controller),
                          ),
                      };
                    },
                  ),
                ),
              ),
            PlayerMediaKitInitialized() => ClipRect(
                child: SizedBox.expand(
                  child: Builder(
                    builder: (context) {
                      return switch ((widget.aspectRation != null) ||
                          widget.keepAspectRatio) {
                        true => CenterAspectRatio(
                            aspectRatio: _calculateMediaKitAspectRatio(state),
                            child: Video(
                              controller: state.controller,
                              controls: null,
                            ),
                          ),
                        false => Video(
                            controller: state.controller,
                            controls: null,
                          ),
                      };
                    },
                  ),
                ),
              )
          };
        },
      ),
    );
  }

  double _calculateNativeAspectRatio(PlayerNativeInitialized state) {
    final ratio = state.controller.value.aspectRatio;
    return widget.aspectRation ??
        (ratio == 1.0 ? defaultPlayerAspectRatio : ratio);
  }

  double _calculateMediaKitAspectRatio(PlayerMediaKitInitialized state) {
    final videoAspectRatio = calculateVideoAspectRatio(
      state.controller.player.state.width,
      state.controller.player.state.height,
    );
    return widget.aspectRation ??
        (videoAspectRatio == 1.0 ? defaultPlayerAspectRatio : videoAspectRatio);
  }

  void _loadUri(Uri uri) {
    _tryNotifyController(null);
    final minLoadingDuration = widget.videoLoadingStyle?.minDuration;
    context.read<PlayerBloc>().add(
          PlayerCreate(
            uri: uri,
            minLoadingDuration: minLoadingDuration ?? Duration.zero,
            httpHeaders: widget.httpHeaders,
            engine: widget.engine,
            autoPlay: widget.autoPlay,
          ),
        );
  }
}
