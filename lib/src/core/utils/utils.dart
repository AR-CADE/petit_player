import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

double calculateAspectRatio(BuildContext context, Size screenSize) {
  final width = screenSize.width;
  final height = screenSize.height;
  return width > height ? width / height : height / width;
}

VideoPlayerController getController(
  Uri uri, {
  bool offline = true,
  Map<String, String> httpHeaders = const <String, String>{},
  Future<ClosedCaptionFile>? closedCaptionFile,
  VideoPlayerOptions? videoPlayerOptions,
}) {
  if (offline == false) {
    return VideoPlayerController.networkUrl(
      uri,
      httpHeaders: httpHeaders,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
    );
  }

  return VideoPlayerController.file(
    File.fromUri(uri),
    closedCaptionFile: closedCaptionFile,
    videoPlayerOptions: videoPlayerOptions,
  );
}

Future<void> fastForward(
  VideoPlayerController controller, {
  int seekTo = 10,
}) async {
  if (controller.value.duration.inSeconds -
          controller.value.position.inSeconds >
      seekTo) {
    await controller.seekTo(
      Duration(seconds: controller.value.position.inSeconds + seekTo),
    );
  }
}

Future<void> rewind(
  VideoPlayerController controller, {
  int seekTo = 10,
}) async {
  if (controller.value.position.inSeconds > seekTo) {
    await controller.seekTo(
      Duration(seconds: controller.value.position.inSeconds - seekTo),
    );
  } else {
    await controller.seekTo(Duration.zero);
  }
}

bool isNetwork(Uri uri) {
  final netRegex = RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
  return netRegex.hasMatch(uri.toString());
}
