import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petit_player/src/core/style/video_loading_style.dart';
import 'package:petit_player/src/core/utils/utils.dart';
import 'package:petit_player/src/presentation/player/player.dart';

class PetitPlayer extends StatefulWidget {
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
  State<PetitPlayer> createState() => _PetitPlayerState();
}

class _PetitPlayerState extends State<PetitPlayer> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayerBloc(),
      child: PlayerView(
        uri: widget.uri,
        videoLoadingStyle: widget.videoLoadingStyle,
        streamController: widget.streamController,
        autoPlay: widget.autoPlay,
        aspectRation: widget.aspectRation,
        keepAspectRatio: widget.keepAspectRatio,
        httpHeaders: widget.httpHeaders,
        engine: widget.engine,
      ),
    );
  }
}
