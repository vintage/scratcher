# scratcher

Scratchable widget which temporarily hides content from user.

[![Version](https://img.shields.io/badge/version-0.0.5-blue.svg)](https://pub.dartlang.org/packages/scratcher)

## Features

- Cover content with color
- Cover content with image
- Smooth calculations
- Fully configurable

![Screen 1](https://github.com/vintage/scratcher/blob/master/screens/screen_1.png?raw=true "Screen #1")
![Screen 2](https://github.com/vintage/scratcher/blob/master/screens/screen_2.png?raw=true "Screen #2")
![Screen 3](https://github.com/vintage/scratcher/blob/master/screens/screen_3.png?raw=true "Screen #3")

## Getting started

You should ensure that you add the scratcher as a dependency in your Flutter project.
```yaml
dependencies:
 scratcher: "^0.0.5"
```

You should then run `flutter packages upgrade` or update your packages in IntelliJ.

## Example Project

There is a crazy example project in the `example` folder. Check it out to see most of the available options.

## Setting up

First, you need to import the scratcher:
```dart
import 'package:scratcher/scratcher.dart';
```

Now you are ready to cover any widget with the scratchy area:

```dart
Scratcher(
  brushSize: 30,
  threshold: 50,
  color: Colors.red,
  onChange: (value) { print("Scratch progress: $value%"); },
  onThreshold: () { print("Threshold reached, you won!"); },
  child: Container(
    height: 300,
    width: 300,
    color: Colors.blue,
  ),
)
```
