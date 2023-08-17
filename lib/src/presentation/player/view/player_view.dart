import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petit_player/petit_player.dart';
import 'package:petit_player/src/core/style/loader.dart';
import 'package:petit_player/src/presentation/player/widgets/fvp_texture_player.dart';
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
    this.background = Colors.transparent,
    this.engine = PlayerEngine.native,
    this.fvpOptions,
  });

  /// Video source
  final Uri uri;

  /// Video Loading Style
  final VideoLoadingStyle? videoLoadingStyle;

  /// A Stream Controller of VideoPlayerController
  final StreamController<PlayerState>? streamController;

  /// Auto Play on init
  final bool autoPlay;

  /// HttpHeaders for network VideoPlayerController
  final Map<String, String> httpHeaders;

  /// Aspect Ratio (Any value > 0 is valid)
  final double? aspectRation;

  /// Keep Aspect Ratio,
  /// NOTE : if `aspectRation` is set, `keepAspectRatio` will be set to true
  final bool keepAspectRatio;

  /// Background Color,
  final Color background;

  /// Player engine (curently supported : 'native (default)', 'fvp')
  /// NOTE: FVP renderer works on Android, iOS, Linux, macOS and Windows but not Web (see more at: https://pub.dev/packages/fvp)
  final PlayerEngine engine;

  /// The Options to pass to FVP
  final Map<String, dynamic>? fvpOptions;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  @override
  void initState() {
    super.initState();
    _loadUri();
  }

  @override
  void didUpdateWidget(covariant PlayerView oldWidget) {
    if (oldWidget.uri != widget.uri) {
      _loadUri();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _loadUri() {
    context.read<PlayerBloc>().add(_createPlayer());
  }

  PlayerCreate _createPlayer() {
    return PlayerCreate(
      uri: widget.uri,
      minLoadingDuration:
          widget.videoLoadingStyle?.minDuration ?? Duration.zero,
      httpHeaders: widget.httpHeaders,
      autoPlay: widget.autoPlay,
      streamController: widget.streamController,
      engine: widget.engine,
      fvpOptions: widget.fvpOptions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.background,
      child: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          return ColoredBox(
            color: widget.background,
            child: Builder(
              builder: (context) {
                if (state == const PlayerLoading() ||
                    state == const PlayerUninitialized()) {
                  return Center(
                    child: widget.videoLoadingStyle?.loading ?? const Loader(),
                  );
                }

                switch (state) {
                  case PlayerInitialized():
                    return ClipRect(
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox.expand(
                        child: switch ((widget.aspectRation != null) ||
                            widget.keepAspectRatio) {
                          true => Center(
                              child: AspectRatio(
                                aspectRatio: _calculateAspectRatio(state)!,
                                child: VideoPlayer(state.controller),
                              ),
                            ),
                          false => VideoPlayer(state.controller)
                        },
                      ),
                    );
                  case PlayerFvpInitialized():
                    return ClipRect(
                      child: SizedBox.expand(
                        child: switch ((widget.aspectRation != null) ||
                            widget.keepAspectRatio) {
                          true => Center(
                              child: AspectRatio(
                                aspectRatio: _calculateAspectRatio(state)!,
                                child: FvpTexturePlayer(
                                  textureId: state.player.textureId,
                                ),
                              ),
                            ),
                          false => FvpTexturePlayer(
                              textureId: state.player.textureId,
                            )
                        },
                      ),
                    );
                  case PlayerLoading():
                  case PlayerUninitialized():
                    throw Exception('Unsuported player');
                }
              },
            ),
          );
        },
      ),
    );
  }

  double? _calculateAspectRatio(PlayerState state) {
    return switch (state) {
      PlayerInitialized() => _calculateNativeAspectRatio(state),
      PlayerFvpInitialized() => _calculateFvpAspectRatio(state),
      PlayerLoading() => null,
      PlayerUninitialized() => null,
    };
  }

  double _calculateNativeAspectRatio(PlayerInitialized state) {
    final ratio = state.controller.value.aspectRatio;
    final computedRatio = widget.aspectRation ??
        (ratio == 1.0 ? defaultPlayerAspectRatio : ratio);
    return computedRatio > 0.0 ? computedRatio : 1.0;
  }

  double _calculateFvpAspectRatio(PlayerFvpInitialized state) {
    const videoAspectRatio = 1.0;
    final computedRatio = widget.aspectRation ??
        (videoAspectRatio == 1.0 ? defaultPlayerAspectRatio : videoAspectRatio);
    return computedRatio > 0.0 ? computedRatio : 1.0;
  }
}
