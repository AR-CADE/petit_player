import 'package:bloc/bloc.dart' show Bloc, Emitter;
import 'package:bloc_concurrency/bloc_concurrency.dart' show restartable;
import 'package:equatable/equatable.dart' show Equatable;
import 'package:petit_player/src/core/utils/utils.dart'
    show getController, isNetwork;
import 'package:rxdart/streams.dart' show ForkJoinStream, TimerStream;
import 'package:video_player/video_player.dart' show VideoPlayerController;

part 'player_event.dart';
part 'player_state.dart';

/// {@template player_bloc}
/// Bloc which manages the current [PlayerState]
/// {@endtemplate}
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(PlayerLoading()) {
    on<PlayerCreate>(
      (event, emit) async {
        await dispose();

        emit(PlayerLoading());

        final urlIsNetwork = isNetwork(event.uri);

        _controller = getController(
          event.uri,
          offline: !urlIsNetwork,
          httpHeaders: event.httpHeaders,
        );

        await emit.onEach<void>(
          ForkJoinStream.list<void>([
            TimerStream(null, event.minLoadingDuration),
            _controller!.initialize().asStream()
          ]),
          onData: (_) {
            if (_controller!.value.isInitialized) {
              add(_PlayerInitialized(_controller!));
            }
          },
        );
      },
      transformer: restartable(),
    );

    on<_PlayerInitialized>(
      (event, emit) => emit(PlayerInitialized(event.controller)),
    );

    on<PlayerDispose>(_onPlayerDispose);
  }

  /// Video Player Controller
  VideoPlayerController? _controller;

  Future<void> dispose() async {
    await _controller?.pause();
    await _controller?.dispose();
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
