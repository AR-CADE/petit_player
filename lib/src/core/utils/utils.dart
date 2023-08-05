import 'dart:io';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';

enum PlayerEngine { native, mediaKit }

const defaultPlayerAspectRatio = 16 / 9;

double calculateVideoAspectRatio(int? width, int? height) {
  final w = width ?? 1;
  final h = height ?? 1;

  if (w == 0 || h == 0) {
    return 1;
  }

  if (w < 0 || h < 0) {
    return 1;
  }

  return w / h;
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

Future<void> nativeFastForward(
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

Future<void> nativeRewind(
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

Future<void> mediaKitFastForward(
  VideoController controller, {
  int seekTo = 10,
}) async {
  if (controller.player.state.duration.inSeconds -
          controller.player.state.position.inSeconds >
      seekTo) {
    await controller.player.seek(
      Duration(seconds: controller.player.state.position.inSeconds + seekTo),
    );
  }
}

Future<void> mediaKitRewind(
  VideoController controller, {
  int seekTo = 10,
}) async {
  if (controller.player.state.position.inSeconds > seekTo) {
    await controller.player.seek(
      Duration(seconds: controller.player.state.position.inSeconds - seekTo),
    );
  } else {
    await controller.player.seek(Duration.zero);
  }
}

bool isNetwork(Uri uri) {
  final netRegex = RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
  return netRegex.hasMatch(uri.toString());
}
