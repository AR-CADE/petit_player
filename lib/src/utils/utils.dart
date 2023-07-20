import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

double calculateAspectRatio(BuildContext context, Size screenSize) {
  final width = screenSize.width;
  final height = screenSize.height;
  return width > height ? width / height : height / width;
}

VideoPlayerController getController(
  Uri uri,
  bool offline, {
  Map<String, String> httpHeaders = const <String, String>{},
  Future<ClosedCaptionFile>? closedCaptionFile,
  VideoPlayerOptions? videoPlayerOptions,
}) {
  if (offline == false) {
    return VideoPlayerController.networkUrl(uri,
        httpHeaders: httpHeaders,
        closedCaptionFile: closedCaptionFile,
        videoPlayerOptions: videoPlayerOptions);
  }

  return VideoPlayerController.file(File.fromUri(uri),
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions);
}

Future<void> fastForward({required VideoPlayerController controller}) async {
  if (controller.value.duration.inSeconds -
          controller.value.position.inSeconds >
      10) {
    await controller
        .seekTo(Duration(seconds: controller.value.position.inSeconds + 10));
  }
  if (!controller.value.isPlaying) {}
}

Future<void> rewind(VideoPlayerController controller) async {
  if (controller.value.position.inSeconds > 10) {
    await controller
        .seekTo(Duration(seconds: controller.value.position.inSeconds - 10));
  } else {
    await controller.seekTo(const Duration(seconds: 0));
  }
  if (!controller.value.isPlaying) {}
}

bool isNetwork(Uri uri) {
  final netRegex = RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
  return netRegex.hasMatch(uri.toString());
}
