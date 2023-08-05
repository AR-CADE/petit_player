import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:petit_player/petit_player.dart';

void main() {
  if (!kIsWeb) {
    MediaKit.ensureInitialized();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'petit_player example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse('https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 720,
              child: PetitPlayer(
                engine: kIsWeb ? PlayerEngine.native : PlayerEngine.mediaKit,
                uri: uri,
                autoPlay: !kIsWeb,
                keepAspectRatio: false,
              ),
            ),
            const Visibility(
              visible: kIsWeb,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(
                      // ignore: lines_longer_than_80_chars
                      'Right-click the black rectangle to show the contex menu,',
                      style: TextStyle(color: Colors.red, fontSize: 32),
                    ),
                    Text(
                      "and select 'Show Controls' or 'Play' to start the video",
                      style: TextStyle(color: Colors.red, fontSize: 32),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
