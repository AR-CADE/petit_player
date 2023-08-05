part of 'player_bloc.dart';

/// {@template player_event}
/// Base class for all [PlayerEvent]s which are
/// handled by the [PlayerBloc].
/// {@endtemplate}
sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object> get props => [];
}

/// {@template player_create}
/// Signifies to the [PlayerBloc] that the user
/// has requested to create a video controller.
/// {@endtemplate}
final class PlayerCreate extends PlayerEvent {
  const PlayerCreate({
    required this.uri,
    this.httpHeaders = const <String, String>{},
    this.minLoadingDuration = Duration.zero,
    this.engine = PlayerEngine.native,
    this.autoPlay = true,
  });

  final Uri uri;
  final Map<String, String> httpHeaders;
  final Duration minLoadingDuration;
  final PlayerEngine engine;
  final bool autoPlay;
}

final class _PlayerNativeInitialized extends PlayerEvent {
  const _PlayerNativeInitialized(this.controller);

  /// The current controller.
  final VideoPlayerController controller;

  @override
  List<Object> get props => [controller];
}

final class _PlayerMediaKitInitialized extends PlayerEvent {
  const _PlayerMediaKitInitialized(this.controller);

  /// The current controller.
  final VideoController controller;

  @override
  List<Object> get props => [controller];
}

final class PlayerDispose extends PlayerEvent {
  @override
  List<Object> get props => [];
}
