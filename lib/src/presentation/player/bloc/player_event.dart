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
/// has requested to create the [VideoPlayerController].
/// {@endtemplate}
final class PlayerCreate extends PlayerEvent {
  const PlayerCreate({
    required this.uri,
    this.httpHeaders = const <String, String>{},
    this.minLoadingDuration = Duration.zero,
  });

  final Uri uri;
  final Map<String, String> httpHeaders;
  final Duration minLoadingDuration;
}

final class _PlayerInitialized extends PlayerEvent {
  const _PlayerInitialized(this.controller);

  /// The current contreoller.
  final VideoPlayerController controller;

  @override
  List<Object> get props => [controller];
}

final class PlayerDispose extends PlayerEvent {
  @override
  List<Object> get props => [];
}
