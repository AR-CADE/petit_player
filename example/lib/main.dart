// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:petit_player/fvp_pollyfill.dart' as mdk;
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
    final uri0 = Uri.parse(
      'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
    );
    final uri9 = Uri.parse(
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
    );
    final uri10 = Uri.parse(
      'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8',
    );
    final uri11 = Uri.parse(
      'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
    );
    final uri12 = Uri.parse(
      'https://assets.afcdn.com/video49/20210722/v_645516.m3u8',
    );
    final uri13 = Uri.parse(
      'http://amssamples.streaming.mediaservices.windows.net/91492735-c523-432b-ba01-faba6c2206a2/AzureMediaServicesPromo.ism/manifest(format=m3u8-aapl)',
    );
    final uri14 = Uri.parse(
      'http://vjs.zencdn.net/v/oceans.mp4',
    );
    final uri15 = Uri.parse(
      'https://diceyk6a7voy4.cloudfront.net/e78752a1-2e83-43fa-85ae-3d508be29366/hls/fitfest-sample-1_Ott_Hls_Ts_Avc_Aac_16x9_1280x720p_30Hz_6.0Mbps_qvbr.m3u8',
    );
    final uri16 = Uri.parse(
      'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    );
    final uri17 = Uri.parse(
      'https://res.cloudinary.com/dannykeane/video/upload/sp_full_hd/q_80:qmax_90,ac_none/v1/dk-memoji-dark.m3u8',
    );
    final uri18 = Uri.parse(
      'https://d1gnaphp93fop2.cloudfront.net/videos/multiresolution/rendition_new10.m3u8',
    );
    final uri19 = Uri.parse(
      'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
    );
    final uri20 = Uri.parse(
      'http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8',
    );

    final uri21 = Uri.parse(
      'http://walterebert.com/playground/video/hls/sintel-trailer.m3u8',
    );
    final uri22 = Uri.parse(
      'http://content.jwplatform.com/manifests/vM7nH0Kl.m3u8',
    );

    final uri24 = Uri.parse(
      'http://cdn-fms.rbs.com.br/vod/hls_sample1_manifest.m3u8',
    );
    final uri25 = Uri.parse(
      'http://playertest.longtailvideo.com/adaptive/wowzaid3/playlist.m3u8',
    );
    final uri26 = Uri.parse(
      'http://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8',
    );

    final opts = <String, dynamic>{};
    if (!kIsWeb) {
      if (Platform.isLinux) {
        opts['video.decoders'] = [
          'hap',
          'VAAPI:display=drm:interop=drm2:composed=1:external=1:threads=6',
          'FFmpeg:hwcontext=vulkan:drop=0:external=1:reuse=1:threads=6',
          'VDPAU:threads=6',
          'dav1d',
        ];
      }
    }

    opts['lowLatency'] = 1;
    final playerStateStreamController = StreamController<PlayerState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Flexible(
              child: SizedBox(
                //height: 720,
                child: PetitPlayer(
                  streamController: playerStateStreamController,
                  engine: kIsWeb ? PlayerEngine.native : PlayerEngine.fvp,
                  uri: uri16,
                  autoPlay: !kIsWeb,
                  fvpOptions: opts,
                ),
              ),
            ),
            const Flexible(
              child: Visibility(
                visible: kIsWeb,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        'To show the video contoller:',
                        style: TextStyle(color: Colors.red, fontSize: 32),
                      ),
                      Text(
                        // ignore: lines_longer_than_80_chars
                        "Right-click on the video to show the contex menu, and select 'Show Controls'",
                        style: TextStyle(color: Colors.red, fontSize: 32),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
                return FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      data.player.state == mdk.PlaybackState.playing
                          ? data.player.state = mdk.PlaybackState.paused
                          : data.player.state = mdk.PlaybackState.playing;
                    });
                  },
                  child: Icon(
                    data.player.state == mdk.PlaybackState.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                );
              default:
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
