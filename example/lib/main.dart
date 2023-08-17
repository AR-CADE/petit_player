import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:petit_player/petit_player.dart';

void main() {
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
    // final uri = Uri.parse(
    //   'https://cfd-v4-service-channel-stitcher-use1-1.prd.pluto.tv/stitch/hls/channel/6304f20c941c5d00089634e7/master.m3u8?advertisingId&appName=web&terminate=false&appVersion=1&architecture&buildVersion&clientTime&deviceDNT=false&deviceId=d2ac77c8-fa01-4393-b7db-7560473c8809&deviceLat=0&deviceLon=0&deviceMake=flutter&deviceModel=web&deviceType=web&deviceVersion=flutter_current_version&includeExtendedEvents=false&marketingRegion=EARTH&country=EARTH&serverSideAds=false&sid=987b6e06-c93b-412c-a8f3-12bcf7dee920&clientID=d2ac77c8-fa01-4393-b7db-7560473c8809&clientModelNumber=1.0.0&clientDeviceType=0&sessionID&userId',
    // );

    final uri = Uri.parse('https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8');
    final opts = <String, dynamic>{};
    opts['video.decoders'] = ['FFmpeg'];
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
                engine: kIsWeb ? PlayerEngine.native : PlayerEngine.fvp,
                uri: uri,
                autoPlay: !kIsWeb,
                fvpOptions: opts,
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
                    ),
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
