/// fv_dummy library
/// A Simple and naive mdk dummy class,
/// that help to compile with flutter web
library;

export 'package:fvp/mdk.dart'
    if (dart.library.html) 'package:petit_player/src/core/utils/fvp_dummy.dart';
