import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:petit_player/src/style/loader.dart';
import 'package:petit_player/src/utils/utils.dart';
import 'package:video_player/video_player.dart';
import 'package:petit_player/src/style/video_loading_style.dart';

class PetitPlayer extends StatefulWidget {
  /// Video source
  final String url;

  /// Video Loading Style
  final VideoLoadingStyle? videoLoadingStyle;

  /// On Video controller Initialized
  final void Function(VideoPlayerController controller)? onInitialized;

  /// On Video controller disposed
  final void Function()? onDispose;

  /// Auto Play on init
  final bool autoPlay;

  /// HttpHeaders for network VideoPlayerController
  final Map<String, String> httpHeaders;

  const PetitPlayer({
    Key? key,
    required this.url,
    this.videoLoadingStyle,
    this.onInitialized,
    this.onDispose,
    this.autoPlay = true,
    this.httpHeaders = const <String, String>{},
  }) : super(key: key);

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
    loadUrl(widget.url);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PetitPlayer oldWidget) {
    if (oldWidget.url != widget.url) {
      loadUrl(widget.url);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    final onDispose = widget.onDispose;

    if (onDispose != null) {
      onDispose();
    }
    futureInitializedVideoController = null;
    controller?.pause();
    controller?.dispose();
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
            final onInitialized = widget.onInitialized;

            if (onInitialized != null) {
              onInitialized(data);
            }

            return ClipRect(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                    child: AspectRatio(
                  aspectRatio: data.value.aspectRatio,
                  child: VideoPlayer(data),
                )),
              ),
            );
          } else {
            return Center(
                child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: widget.videoLoadingStyle != null
                        ? widget.videoLoadingStyle?.loading
                        : const Loader()));
          }
        });
  }

  Future<void> loadUrl(String url) async {
    futureInitializedVideoController = null;
    await controller?.pause();
    await controller?.dispose();
    final onDispose = widget.onDispose;

    if (onDispose != null) {
      onDispose();
    }

    await videoInit(url);
    setState(() {});
  }

  Future<void> videoInit(String url) async {
    final urlIsNetwork = await compute(isNetwork, url);
    final bool offline = !urlIsNetwork;

    controller = getController(url, offline, httpHeaders: widget.httpHeaders);

    futureInitializedVideoController =
        controller?.initialize().asStream().map((_) {
      if (widget.autoPlay) {
        controller?.play().then((value) => setState(() {}));
      } else {
        setState(() {});
      }
      return controller;
    }).first;
  }
}
