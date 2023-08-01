part of 'player_bloc.dart';

/// {@template player_state}
/// Base class for all [PlayerState]s which are
/// managed by the [PlayerBloc].
/// {@endtemplate}
sealed class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object> get props => [];
}

/// The initial state until the of the [VideoPlayerController] is inititialized.
final class PlayerLoading extends PlayerState {
  const PlayerLoading();
}

/// {@template player_initialized}
/// The state of the [PlayerBloc] after
/// the [VideoPlayerController] has been inititialized.
/// {@endtemplate}
final class PlayerInitialized extends PlayerState {
  const PlayerInitialized(this.controller);

  /// The current controller.
  final VideoPlayerController controller;

  @override
  List<Object> get props => [controller];
}
