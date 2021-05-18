# scratcher

Scratch card widget which temporarily hides content from user.

[![Version](https://img.shields.io/badge/pub-v2.1.0-blue.svg)](https://pub.dartlang.org/packages/scratcher)

![Demo](https://media.giphy.com/media/fXztsRTXoKsVuChtTl/giphy.gif)

## Features

- Android and iOS support
- Cover content with full color or custom image 
- Track the scratch progress and threshold
- Fully configurable

## Getting started

1. First thing you need to do is adding the scratcher as a project dependency in `pubspec.yaml`:
```yaml
dependencies:
 scratcher: "^2.1.0"
```

2. Now you can install it by running `flutter pub get` or through code editor.

## Setting up

1. Import the library:
```dart
import 'package:scratcher/scratcher.dart';
```

2. Cover desired widget with the scratch card:

```dart
Scratcher(
  brushSize: 30,
  threshold: 50,
  color: Colors.red,
  onChange: (value) => print("Scratch progress: $value%"),
  onThreshold: () => print("Threshold reached, you won!"),
  child: Container(
    height: 300,
    width: 300,
    color: Colors.blue,
  ),
)
```

## Properties

Property | Type | Description
--- | --- | ---
child | Widget | Widget rendered under the scratch area.
enabled | bool | Whether new scratches can be applied.
threshold | double | Percentage level of scratch area which should be revealed to complete.
brushSize | double | Size of the brush. The bigger it is the faster user can scratch the card.
accuracy | ScratchAccuracy | Determines how accurate the progress should be reported. Lower accuracy means higher performance.
color | Color | Color used to cover the child widget.
image | Image | Image widget used to cover the child widget.
rebuildOnResize | bool | Determines if the scratcher should rebuild itself when space constraints change (resize).
onChange | Function | Callback called when new part of area is revealed (min 0.1% difference).
onThreshold | Function | Callback called when threshold is reached (only when defined).
onScratchStart | Function | Callback called when scratching starts.
onScratchUpdate | Function | Callback called during scratching.
onScratchEnd | Function | Callback called when scratching ends.

## Programmatic access

You can control the Scratcher programmatically by assigning the `GlobalKey` to the widget.

```dart
final scratchKey = GlobalKey<ScratcherState>();

Scratcher(
  key: scratchKey,
  // remaining properties
)
```

After assigning the key, you can call any exposed methods e.g.:

```dart
RaisedButton(
  child: const Text('Reset'),
  onPressed: () {
    scratchKey.currentState.reset(duration: Duration(milliseconds: 2000));
  },
);
```

Method | Description
--- | ---
reset | Resets the scratcher state to the initial values.
reveal | Reveals the whole scratcher, so than only original child is displayed.

## Example Project

There is a crazy example project in the `example` folder. Check it out to see most of the available options.

## Resources

- [https://www.youtube.com/watch?v=EM4D1pUpadA](https://www.youtube.com/watch?v=EM4D1pUpadA) by The CS Guy
