import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petit_player/src/core/style/video_loading_style.dart';
import 'package:petit_player/src/presentation/player/player.dart';
import 'package:video_player/video_player.dart';

class PetitPlayer extends StatefulWidget {
  const PetitPlayer({
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
        httpHeaders: widget.httpHeaders,
      ),
    );
  }
}
