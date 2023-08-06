import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petit_player/src/core/style/video_loading_style.dart';
import 'package:petit_player/src/core/utils/utils.dart';
import 'package:petit_player/src/presentation/player/player.dart';

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
    this.engine = PlayerEngine.native,
  });

  /// Player engine (curently supported : 'native (default)', 'mediaKit')
  final PlayerEngine engine;

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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayerBloc(),
      child: PlayerView(
        uri: uri,
        videoLoadingStyle: videoLoadingStyle,
        streamController: streamController,
        autoPlay: autoPlay,
        aspectRation: aspectRation,
        keepAspectRatio: keepAspectRatio,
        httpHeaders: httpHeaders,
        engine: engine,
      ),
    );
  }
}
