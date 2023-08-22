/// a Simple and naive mdk dummy class,
/// that help to compile with flutter web
///
// TODO(me): Remove this file if fvp fully pollyfill all public symbols.
class MdkVideoPlayer {
  static dynamic registerVideoPlayerPlatformsWith({dynamic options}) {}
}

// ignore: non_constant_identifier_names
dynamic PlaybackState;
// ignore: non_constant_identifier_names
dynamic State;

class Player {
  dynamic dispose() {}
  dynamic updateTexture({dynamic width, dynamic height, dynamic fit}) {}
  dynamic setDecoders(dynamic type, dynamic value) {}
  dynamic setActiveTracks(dynamic type, dynamic value) {}
  dynamic setMedia(dynamic uri, dynamic type) {}
  dynamic setNext(dynamic uri, {dynamic from, dynamic seekFlag}) {}
  dynamic waitFor(dynamic state, {dynamic timeout}) {}
  dynamic seek({dynamic position, dynamic flags, dynamic callback}) {}
  dynamic buffered() {}
  dynamic setBufferRange({dynamic min, dynamic max, dynamic drop}) {}
  dynamic setRange({dynamic from, dynamic to}) {}
  dynamic getProperty(dynamic name) {}
  dynamic setVideoSurfaceSize(dynamic width, dynamic height, {dynamic vid}) {}
  dynamic setVideoViewport(
    dynamic x,
    dynamic y,
    dynamic width,
    dynamic height, {
    dynamic vid,
  }) {}
  dynamic setAspectRatio(dynamic value, {dynamic vid}) {}
  dynamic rotate(dynamic degree, {dynamic vid}) {}
  dynamic scale(dynamic x, dynamic y, {dynamic vid}) {}
  dynamic setBackgroundColor(
    dynamic r,
    dynamic g,
    dynamic b,
    dynamic a, {
    dynamic vid,
  }) {}
  dynamic setBackground(dynamic c, {dynamic vid}) {}
  dynamic setVideoEffect(dynamic effect, dynamic value, {dynamic vid}) {}
  dynamic setColorSpace(dynamic value, {dynamic vid}) {}
  dynamic onEvent(dynamic callback) {}
  dynamic onStateChanged(dynamic callback, {dynamic reply}) {}
  dynamic onMediaStatusChanged(dynamic callback, {dynamic reply}) {}
  dynamic state;
  dynamic textureId;
  dynamic media;
  dynamic loop;
  dynamic videoDecoders;
}
