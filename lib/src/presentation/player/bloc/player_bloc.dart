import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:petit_player/src/core/utils/utils.dart';
import 'package:video_player/video_player.dart';

part 'player_event.dart';
part 'player_state.dart';

/// {@template player_bloc}
/// Bloc which manages the current [PlayerState]
/// {@endtemplate}
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerUninitialized()) {
    _tryNotifyController(const PlayerUninitialized());

    on<PlayerCreate>(
      (event, emit) async {
        await dispose();

        _streamController = event.streamController;

        emit(const PlayerLoading());
        _tryNotifyController(const PlayerLoading());

        await _getNativeInitializedController(event, emit);
      },
      transformer: restartable(),
    );

    on<_PlayerInitialized>(
      (event, emit) {
        final state = PlayerInitialized(event.controller);
        _tryNotifyController(state);
        emit(state);
      },
    );

    on<PlayerDispose>(_onPlayerDispose);
  }

  Future<void> _getNativeInitializedController(
    PlayerCreate event,
    Emitter<PlayerState> emit,
  ) async {
    final urlIsNetwork = isNetwork(event.uri);

    _nativeController = getController(
      event.uri,
      offline: !urlIsNetwork,
      httpHeaders: event.httpHeaders,
    );

    await Future.wait<void>([
      Future.delayed(event.minLoadingDuration),
      _nativeController!.initialize()
    ]).then((_) async {
      if (_nativeController!.value.isInitialized) {
        if (event.autoPlay) {
          await _nativeController!.play();
        }
        add(_PlayerInitialized(_nativeController!));
      }
    });
  }

  void _tryNotifyController(PlayerState state) {
    final streamController = _streamController;
    if (streamController != null && streamController.isClosed == false) {
      streamController.add(state);
    }
  }

  /// Video Player Controller
  VideoPlayerController? _nativeController;

  StreamController<PlayerState>? _streamController;

  Future<void> dispose() async {
    _tryNotifyController(const PlayerUninitialized());
    await _nativeController?.pause();
    await _nativeController?.dispose();
    _nativeController = null;
    _streamController = null;
  }

  Future<void> _onPlayerDispose(
    PlayerDispose event,
    Emitter<PlayerState> emit,
  ) {
    return dispose();
  }

  @override
  Future<void> close() {
    dispose();
    return super.close();
  }
}
