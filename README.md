# petit_player plugin

petit_player plugin is a tiny wrapper aroud for video_player that can simplify connection to online ressources (especially HLS).

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  petit_player: ^1.0.0
```

## Usage

Then you just have to import the package with

```dart
import 'package:petit_player/petit_player.dart';
```

## Example

```dart
    Center(
        child: Column(
            children: [
            Container(
                height: 600,
                child: PetitPlayer(
                url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
                ),
            ),
            ],
        ),
    ),
```
