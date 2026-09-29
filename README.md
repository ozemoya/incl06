# Smiley Painter Lab

A Flutter drawing app for In-Class Activity 06 by Myles Miller. It uses `CustomPainter` to build responsive faces from canvas measurements and updates them as the user changes mood, style, and accessories.

## Features

- Three selectable faces: Classic, Sleepy, and Surprised.
- Mood slider that changes mouth geometry and face color across low, calm, and happy ranges.
- Eye size, eye spacing, and blush controls.
- Tap the face to cycle styles; long press to randomize mood and color with one clear message.
- Toggleable hat, glasses, and mustache, with Undo for prior face configurations.
- Scrollable portrait and landscape layout for a phone screen.

## Run and test

```text
flutter pub get
flutter run
flutter analyze
flutter test
flutter build apk --release
```

The release Android install file is generated at `build/app/outputs/flutter-apk/app-release.apk`. The app has no third-party Flutter dependencies.

## How it works

`DrawingPlayground` owns the current `FaceConfig` and Undo history. Controls call `setState`, then pass the updated configuration to `SmileyPainter`. The painter derives its center and radius from the available `Size`, draws the face and features in layer order, and repaints only when a visual input changes. A slider drag creates one Undo entry rather than one entry for every intermediate thumb position.

## Evidence and explanation

- [Undergraduate critical-thinking answer](docs/critical_thinking.md)
- [Paint-order experiment](docs/paint_order.md)
- [Portrait screenshot](docs/images/portrait-classic.png)
- [Landscape screenshot](docs/images/landscape-smiley.png)
- [Three face styles](docs/images/portrait-sleepy.png), [surprised](docs/images/portrait-surprised.png), and [low mood](docs/images/portrait-low-mood.png)

The app was run on a Pixel 7 Pro Android emulator. Flutter analysis and three automated tests passed; the phone-emulator checks covered style switching, mood changes, gestures, accessories, Undo, and portrait and landscape layout.
