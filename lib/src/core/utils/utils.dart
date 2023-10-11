import 'dart:io';
import 'package:petit_player/fvp_pollyfill.dart';
import 'package:video_player/video_player.dart';

enum PlayerEngine { native, fvp }

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

Future<void> fvpFastForward(
  Player player, {
  int seekTo = 10,
}) async {
  if (player.mediaInfo.duration - player.position > seekTo * 1000) {
    await player.seek(position: player.position + (seekTo * 1000));
  }
}

Future<void> fvpRewind(
  Player player, {
  int seekTo = 10,
}) async {
  if (player.position > seekTo * 1000) {
    await player.seek(position: player.position - (seekTo * 1000));
  } else {
    await player.seek(position: 0);
  }
}

bool isNetwork(Uri uri) {
  if (uri.hasScheme) {
    switch (uri.scheme) {
      case 'file':
        return false;

      case 'http':
      case 'https':
        return true;
      default:
    }
  }
  final netRegex = RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
  return netRegex.hasMatch(uri.toString());
}
