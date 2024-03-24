# petit_player plugin

petit_player plugin is a flutter plugin as a tiny wrapper around for video_player that can simplify connection to online ressources (especially HLS).

Since version 1.1.16, this plugin use [FVP](https://github.com/wang-bin/fvp) for video rendering under Linux, Macos ans Windows

## Getting Started

Assuming your already installed flutter on your machine and configured the Android emulator (if not please read the
[online documentation](https://docs.flutter.dev/))

create a new flutter project:

```dart
 flutter create <name_of_your_project>
 ```

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  petit_player:
    git:
      url: https://github.com/AR-CADE/petit_player.git
```

## Usage

Then you just have to import the package with

```dart
import 'package:petit_player/petit_player.dart';
```

## Example

```dart
    Center(
      child: SizedBox(
        height: 600,
        child: PetitPlayer(
          uri: Uri.parse(
              'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'),
        ),
      ),
    ),
```

then just run it and enjoy !!!

# contact
arm-cade@proton.me