import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:petit_player/fvp_pollyfill.dart' as mdk;
import 'package:petit_player/src/core/utils/utils.dart';
import 'package:video_player/video_player.dart';

part 'player_event.dart';
part 'player_state.dart';

/// {@template player_bloc}
/// Bloc which manages the current [PlayerState]
/// {@endtemplate}
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerUninitialized()) {
    on<PlayerCreate>(
      (event, emit) {
        _streamController = event.streamController;

        emit(const PlayerLoading());
        _tryNotifyController(const PlayerLoading());

        switch (event.engine) {
          case PlayerEngine.fvp:
            {
              if (!kIsWeb) {
                _getFvpInitializedController(event, emit);
              }
              break;
            }
          case PlayerEngine.native:
            {
              _getNativeInitializedController(event, emit);
              break;
            }
        }
      },
    );

    on<_PlayerInitialized>(
      (event, emit) {
        final state = PlayerInitialized(event.controller);
        emit(state);
        _tryNotifyController(state);
      },
    );

    on<_PlayerFvpInitialized>(
      (event, emit) {
        final state = PlayerFvpInitialized(event.player);
        emit(state);
        _tryNotifyController(state);
      },
    );

    on<_PlayerDispose>(_onPlayerDispose);
  }

  void _getNativeInitializedController(
    PlayerCreate event,
    Emitter<PlayerState> emit,
  ) {
    final urlIsNetwork = isNetwork(event.uri);

    _nativeController = getController(
      event.uri,
      offline: !urlIsNetwork,
      httpHeaders: event.httpHeaders,
    );

    Future.wait<void>([
      Future.delayed(event.minLoadingDuration),
      _nativeController!.initialize(),
    ]).then((_) {
      if (_nativeController!.value.isInitialized) {
        if (event.autoPlay) {
          _nativeController!.play();
        }
        add(_PlayerInitialized(_nativeController!));
      }
    });
  }

  void _getFvpInitializedController(
    PlayerCreate event,
    Emitter<PlayerState> emit,
  ) {
    _player = mdk.Player();
    final urlIsNetwork = isNetwork(event.uri);
    final media = urlIsNetwork ? event.uri.toString() : event.uri.toFilePath();

    _player!.media = media;
    _player!.loop = 0;
    final videoDecoders = event.fvpOptions?['video.decoders'] as List<String>?;

    if (videoDecoders != null) {
      _player!.videoDecoders = videoDecoders;
    }

    final lowLatency = event.fvpOptions?['lowLatency'] as int?;
    final keepOpen = event.fvpOptions?['keep_open'] as int?;
    final shouldKeepOpen = lowLatency ?? keepOpen ?? 0;

    _player!.setProperty('keep_open', shouldKeepOpen.toString());

    if (event.autoPlay) {
      _player!.state = mdk.PlaybackState.playing;
    }

    Future.wait<void>([
      Future.delayed(event.minLoadingDuration),
      _player!.updateTexture(),
    ]).then((_) {
      add(_PlayerFvpInitialized(_player!));
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

  mdk.Player? _player;

  void _dispose() {
    _tryNotifyController(const PlayerUninitialized());
    _nativeController?.pause();
    _nativeController?.dispose();
    if (!kIsWeb) {
      _player?.state = mdk.PlaybackState.stopped;
      _player?.dispose();
      _player = null;
    }
    _nativeController = null;
    _streamController = null;
  }

  void _onPlayerDispose(
    _PlayerDispose event,
    Emitter<PlayerState> emit,
  ) {
    return _dispose();
  }

  @override
  Future<void> close() {
    _dispose();
    return super.close();
  }
}
