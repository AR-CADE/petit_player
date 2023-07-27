import 'package:flutter/material.dart';
import 'package:petit_player/src/style/loader.dart';

/// Video Loading Style
class VideoLoadingStyle {
  VideoLoadingStyle({
    this.loading = const Loader(),
    this.timeout = Duration.zero,
  });

  /// THe Loader Widget
  final Widget loading;

  /// The minnimum of time this loader will be shown
  final Duration timeout;
}
