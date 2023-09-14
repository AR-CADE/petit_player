import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:petit_player/fvp_pollyfill.dart' as mdk;
import 'package:petit_player/petit_player.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp(args));
}

class MyApp extends StatelessWidget {
  const MyApp(this.args, {super.key});
  final List<String> args;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'petit_player example', args: args),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, required this.args, super.key});

  final String title;
  final List<String> args;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final _files = <File>[];
  final _scan = true;
  Future<File?>? _source;
  StreamController<PlayerState> playerStateStreamController =
      StreamController<PlayerState>();

  @override
  void initState() {
    super.initState();

    if (widget.args.isNotEmpty) {
      late Future<void> afterScan;

      if (widget.args.length == 1) {
        final url = widget.args[0];
        afterScan = _scanUrl(url);
      } else {
        afterScan = Future.wait(widget.args.map(_scanUrl));
      }

      afterScan.then(
        (_) {
          _source = Future.value(
            _files.firstWhere((file) {
              return file.path == widget.args[0];
            }),
          );

          setState(() {});
        },
      );
    } else {}
  }

  Future<void> _scanUrl(String url) async {
    if (FileSystemEntity.isDirectorySync(url)) {
      final entity = Directory(url);
      return scanningFilesWithAsyncRecursive(entity).forEach(_files.add);
    } else {
      final entity = File(url);
      if (_scan) {
        final directory = Directory(entity.parent.absolute.path);

        return scanningFilesWithAsyncRecursive(directory).forEach(_files.add);
      } else if (_isFileSupported(entity)) {
        return _files.add(entity);
      }
    }
  }

  Stream<File> scanningFilesWithAsyncRecursive(
    Directory directory, {
    bool recursive = false,
  }) async* {
    final dirList = directory.list();
    await for (final FileSystemEntity entity in dirList) {
      if (entity is File && _isFileSupported(entity)) {
        yield entity;
      } else if (entity is Directory && recursive) {
        yield* scanningFilesWithAsyncRecursive(Directory(entity.path));
      }
    }
  }

  bool _isFileSupported(File f) {
    final fileExtension = extension(f.path);

    switch (fileExtension.toLowerCase()) {
      case '.mpg':
      case '.mpeg':
      case '.avi':
      case '.divx':
      case '.mov':
      case '.moov':
      case '.mkv':
      case '.mp4':
      case '.mp2':
      case '.flv':
      case '.ts':
      case '.ogv':
      case '.webm':
      case '.rmvb':
      case '.wmv':
      case '.asf':
      case '.m4v':
      case '.3gp':
        return true;
      default:
    }
    return false;
  }

  @override
  void dispose() {
    playerStateStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_source == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            FilePicker.platform.pickFiles().then((result) {
              final url = result?.files.single.path;
              if (url != null) {
                _scanUrl(url).then(
                  (_) {
                    _source = Future.value(
                      _files.firstWhere((file) => file.path == url),
                    );
                    setState(() {});
                  },
                );
              }
            });
          },
          child: const Text('Choose a file to play'),
        ),
      );
    }
    return FutureBuilder<File?>(
      future: _source,
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('Error');
          } else if (snapshot.hasData && file != null) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: PetitPlayer(
                streamController: playerStateStreamController,
                engine: kIsWeb ? PlayerEngine.native : PlayerEngine.fvp,
                uri: file.uri,
                autoPlay: !kIsWeb,
              ),
              floatingActionButton: StreamBuilder<PlayerState>(
                stream: playerStateStreamController.stream,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  if (snapshot.hasData && data != null) {
                    switch (data) {
                      case PlayerInitialized():
                        {
                          if (!data.controller.value.isInitialized) {
                            return const SizedBox.shrink();
                          }
                          return FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                data.controller.value.isPlaying
                                    ? data.controller.pause()
                                    : data.controller.play();
                              });
                            },
                            child: Icon(
                              data.controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                          );
                        }
                      case PlayerFvpInitialized():
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Builder(
                                builder: (context) {
                                  final index = _files.indexOf(file);

                                  return FloatingActionButton(
                                    backgroundColor:
                                        index == 0 ? Colors.grey : null,
                                    onPressed: () {
                                      if (index == 0) {
                                        return;
                                      }
                                      setState(() {
                                        if (index != -1 && index > 0) {
                                          playerStateStreamController.close();
                                          playerStateStreamController =
                                              StreamController<PlayerState>();
                                          _source =
                                              Future.value(_files[index - 1]);

                                          setState(() {});
                                        }
                                      });
                                    },
                                    child: Builder(
                                      builder: (context) {
                                        return const Icon(Icons.skip_previous);
                                      },
                                    ),
                                  );
                                },
                              ),
                              FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    data.player.state ==
                                            mdk.PlaybackState.playing
                                        ? data.player.state =
                                            mdk.PlaybackState.paused
                                        : data.player.state =
                                            mdk.PlaybackState.playing;
                                  });
                                },
                                child: Icon(
                                  data.player.state == mdk.PlaybackState.playing
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  final index = _files.indexOf(file);

                                  return FloatingActionButton(
                                    backgroundColor: index >= _files.length - 1
                                        ? Colors.grey
                                        : null,
                                    onPressed: () {
                                      if (index >= _files.length - 1) {
                                        return;
                                      }

                                      setState(() {
                                        final index = _files.indexOf(file);

                                        if (index != -1 &&
                                            index + 1 < _files.length) {
                                          playerStateStreamController.close();
                                          playerStateStreamController =
                                              StreamController<PlayerState>();
                                          _source =
                                              Future.value(_files[index + 1]);

                                          setState(() {});
                                        }
                                      });
                                    },
                                    child: const Icon(Icons.skip_next),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      default:
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            );
          } else {
            return const Text('Empty data');
          }
        } else {
          return Text('State: ${snapshot.connectionState}');
        }
      },
    );
  }
}
