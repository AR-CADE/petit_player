import 'package:flutter/material.dart';
import 'package:petit_player/src/core/style/loader.dart';

/// Video Loading Style
@immutable
class VideoLoadingStyle {
  const VideoLoadingStyle({
    this.loading = const Loader(),
    this.minDuration = Duration.zero,
  });

  /// THe Loader Widget
  final Widget loading;

  /// The minnimum amount of time this loader will be shown
  final Duration minDuration;
}
