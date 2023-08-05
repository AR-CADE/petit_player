import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:petit_player/src/core/utils/utils.dart';
import 'package:video_player/video_player.dart';

part 'player_event.dart';
part 'player_state.dart';

/// {@template player_bloc}
/// Bloc which manages the current [PlayerState]
/// {@endtemplate}
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(const PlayerLoading()) {
    on<PlayerCreate>(
      (event, emit) async {
        await dispose();

        emit(const PlayerLoading());

        switch (event.engine) {
          case PlayerEngine.mediaKit:
            {
              await _getMediaKitInitializedController(event, emit);
              break;
            }
          case PlayerEngine.native:
            {
              await _getNativeInitializedController(event, emit);
              break;
            }
        }
      },
      transformer: restartable(),
    );

    on<_PlayerNativeInitialized>(
      (event, emit) => emit(PlayerNativeInitialized(event.controller)),
    );

    on<_PlayerMediaKitInitialized>(
      (event, emit) => emit(PlayerMediaKitInitialized(event.controller)),
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
        add(_PlayerNativeInitialized(_nativeController!));
      }
    });
  }

  Future<void> _getMediaKitInitializedController(
    PlayerCreate event,
    Emitter<PlayerState> emit,
  ) async {
    final player = Player(
      configuration: PlayerConfiguration(
        ready: () {
          if (event.autoPlay) {
            Future.wait<void>([
              Future.delayed(event.minLoadingDuration),
              _mediakitController!.player.play()
            ]).then(
              (_) => add(_PlayerMediaKitInitialized(_mediakitController!)),
            );
          } else {
            add(_PlayerMediaKitInitialized(_mediakitController!));
          }
        },
      ),
    );

    _mediakitController = VideoController(player);

    await player.open(
      Media(
        event.uri.toString(),
        httpHeaders: kIsWeb ? null : event.httpHeaders,
      ),
    );

    player.stream.error.listen((error) => debugPrint(error));
  }

  /// Video Player Controller
  VideoPlayerController? _nativeController;

  /// Media Kit Video Controller
  VideoController? _mediakitController;

  Future<void> dispose() async {
    await _nativeController?.pause();
    await _nativeController?.dispose();
    await _mediakitController?.player.pause();
    await _mediakitController?.player.dispose();
    _nativeController = null;
    _mediakitController = null;
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
