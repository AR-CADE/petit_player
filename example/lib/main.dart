import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:petit_player/petit_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: const [
            SizedBox(
              height: 600,
              child: PetitPlayer(
                url: kIsWeb
                    ? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
                    : 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
                autoPlay: !kIsWeb,
              ),
            ),
            if (kIsWeb) ...<Widget>[
              Text(
                  "Right-click the black rectangle and select Show Controls or Play to start the video",
                  style: TextStyle(color: Colors.red))
            ]
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
