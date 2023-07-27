import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:petit_player/src/style/loader.dart';
import 'package:petit_player/src/style/video_loading_style.dart';
import 'package:petit_player/src/utils/utils.dart';
import 'package:video_player/video_player.dart';

class PetitPlayer extends StatefulWidget {
  const PetitPlayer({
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
  final double aspectRation;

  @override
  PetitPlayerState createState() => PetitPlayerState();
}

class PetitPlayerState extends State<PetitPlayer> {
  /// Future Initialized Video Player Controller
  Future<VideoPlayerController?>? futureInitializedVideoController;

  /// Video Player Controller
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    loadUrl(widget.uri);
  }

  @override
  void didUpdateWidget(covariant PetitPlayer oldWidget) {
    if (oldWidget.uri != widget.uri) {
      loadUrl(widget.uri);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller?.pause().then(
          (value) => controller?.dispose().then((value) {
            if (!mounted) {
              return;
            }
            final streamController = widget.streamController;
            if (streamController != null &&
                streamController.isClosed == false) {
              streamController.add(null);
            }
            futureInitializedVideoController = null;
          }),
        );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoPlayerController?>(
      future: futureInitializedVideoController,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData == true &&
            data != null &&
            data.value.isInitialized) {
          final streamController = widget.streamController;

          if (streamController != null && streamController.isClosed == false) {
            streamController.add(data);
          }

          if (widget.autoPlay) {
            data.play();
          }

          return ClipRect(
            child: SizedBox.expand(
              child: Center(
                child: AspectRatio(
                  aspectRatio: data.value.aspectRatio,
                  child: VideoPlayer(data),
                ),
              ),
            ),
          );
        } else {
          return Center(
            child: AspectRatio(
              aspectRatio: widget.aspectRation,
              child: widget.videoLoadingStyle != null
                  ? widget.videoLoadingStyle?.loading
                  : const Loader(),
            ),
          );
        }
      },
    );
  }

  Future<void> loadUrl(Uri uri) async {
    futureInitializedVideoController = null;
    await controller?.pause();
    await controller?.dispose();

    final streamController = widget.streamController;
    if (streamController != null && streamController.isClosed == false) {
      streamController.add(null);
    }

    final timeout = widget.videoLoadingStyle != null
        ? widget.videoLoadingStyle!.timeout
        : Duration.zero;

    Future.delayed(timeout, () async {
      await videoInit(uri);
      setState(() {});
    });
  }

  Future<void> videoInit(Uri uri) async {
    final urlIsNetwork = await compute(isNetwork, uri);

    controller = getController(
      uri,
      offline: !urlIsNetwork,
      httpHeaders: widget.httpHeaders,
    );

    futureInitializedVideoController =
        controller?.initialize().asStream().map((_) {
      return controller;
    }).first;
  }
}
