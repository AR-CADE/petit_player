import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final loading = widget.videoLoadingStyle?.loading;
        switch (state) {
          case PlayerLoading():
          case PlayerUninitialized():
            return Center(
              child: loading ?? const Loader(),
            );
          case PlayerInitialized():
            return ClipRect(
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
            );
        }
      },
    );
  }

  double _calculateNativeAspectRatio(PlayerInitialized state) {
    final ratio = state.controller.value.aspectRatio;
    final computedRatio = widget.aspectRation ??
        (ratio == 1.0 ? defaultPlayerAspectRatio : ratio);
    return computedRatio > 0.0 ? computedRatio : 1.0;
  }
}
