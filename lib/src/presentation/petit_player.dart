import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petit_player/src/core/style/loader.dart';
import 'package:petit_player/src/core/style/video_loading_style.dart';
import 'package:petit_player/src/core/utils/utils.dart';
import 'package:petit_player/src/domain/player/bloc/player_bloc.dart';
import 'package:petit_player/src/presentation/widgets/fvp_texture_player.dart';
import 'package:video_player/video_player.dart';

class PetitPlayer extends StatelessWidget {
  const PetitPlayer({
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

  PlayerCreate _createPlayer() {
    return PlayerCreate(
      uri: uri,
      minLoadingDuration: videoLoadingStyle?.minDuration ?? Duration.zero,
      httpHeaders: httpHeaders,
      autoPlay: autoPlay,
      streamController: streamController,
      engine: engine,
      fvpOptions: fvpOptions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayerBloc()..add(_createPlayer()),
      child: ColoredBox(
        color: background,
        child: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            return switch (state) {
              PlayerInitialized() => ClipRect(
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox.expand(
                    child: switch ((aspectRation != null) || keepAspectRatio) {
                      true => Center(
                          child: AspectRatio(
                            aspectRatio: _calculateAspectRatio(state)!,
                            child: VideoPlayer(state.controller),
                          ),
                        ),
                      false => VideoPlayer(state.controller)
                    },
                  ),
                ),
              PlayerFvpInitialized() => ClipRect(
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox.expand(
                    child: switch ((aspectRation != null) || keepAspectRatio) {
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
                ),
              PlayerLoading() || PlayerUninitialized() => Center(
                  child: videoLoadingStyle?.loading ?? const Loader(),
                ),
            };
          },
        ),
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
    final computedRatio =
        aspectRation ?? (ratio == 1.0 ? defaultPlayerAspectRatio : ratio);
    return computedRatio > 0.0 ? computedRatio : 1.0;
  }

  double _calculateFvpAspectRatio(PlayerFvpInitialized state) {
    const videoAspectRatio = 1.0;
    final computedRatio = aspectRation ??
        (videoAspectRatio == 1.0 ? defaultPlayerAspectRatio : videoAspectRatio);
    return computedRatio > 0.0 ? computedRatio : 1.0;
  }
}
