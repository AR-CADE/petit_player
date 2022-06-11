import 'package:flutter/material.dart';
import 'package:petit_player/src/style/loader.dart';

/// Video Loading Style
class VideoLoadingStyle {
  VideoLoadingStyle({this.loading = const Loader()});

  final Widget loading;
}
