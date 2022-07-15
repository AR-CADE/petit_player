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

  /// On Video Initialized
  final void Function(VideoPlayerController controller)? onInitialized;

  const PetitPlayer({
    Key? key,
    required this.url,
    this.videoLoadingStyle,
    this.onInitialized,
  }) : super(key: key);

  @override
  PetitPlayerState createState() => PetitPlayerState();
}

class PetitPlayerState extends State<PetitPlayer> {
  /// Video Player Controller
  VideoPlayerController? videoController;

  Future<VideoPlayerController>? initializeVideoPlayerFuture;

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
    videoController?.pause().then((value) =>
        videoController?.dispose().then((value) => videoController = null));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoPlayerController>(
        future: initializeVideoPlayerFuture,
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
    await videoController?.pause();
    initializeVideoPlayerFuture = null;
    videoController?.dispose().then((value) {
      setState(() {
        videoController = null;
      });
    });

    await videoInit(url);
  }

  Future<void> videoInit(String url) async {
    final urlIsNetwork = await compute(isNetwork, url);
    bool offline = !urlIsNetwork;

    final controller = getController(url, offline);

    initializeVideoPlayerFuture = controller.initialize().then((value) async {
      setState(() {
        videoController = controller;
      });
      await videoController?.play();

      return controller;
    });
  }
}
