import 'package:flutter/material.dart' show Widget;
import 'package:petit_player/src/core/style/loader.dart' show Loader;

/// Video Loading Style
class VideoLoadingStyle {
  VideoLoadingStyle({
    this.loading = const Loader(),
    this.minDuration = Duration.zero,
  });

  /// THe Loader Widget
  final Widget loading;

  /// The minnimum amount of time this loader will be shown
  final Duration minDuration;
}
