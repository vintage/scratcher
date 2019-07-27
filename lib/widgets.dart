import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'painter.dart';

const progressReportStep = 0.1;

/// How accurate should the progress be tracked.
enum ScratchAccuracy {
  /// Low accuracy, higher performance.
  low,

  /// High accuracy, lower performance.
  high,
}

double _getAccuracyValue(ScratchAccuracy accuracy) {
  switch (accuracy) {
    case ScratchAccuracy.low:
      return 10.0;
    case ScratchAccuracy.high:
      return 100.0;
  }

  return 0;
}

/// Scratcher widget which covers given child with scratchable overlay.
class Scratcher extends StatefulWidget {
  @override
  _ScratcherState createState() => _ScratcherState();

  Scratcher({
    Key key,
    @required this.child,
    this.threshold,
    this.brushSize = 25,
    this.accuracy = ScratchAccuracy.high,
    this.color = Colors.black,
    this.imagePath,
    this.imageFit = BoxFit.cover,
    this.onChange,
    this.onThreshold,
  }) : super(key: key);

  /// Widget rendered under the scratch area.
  final Widget child;

  /// Percentage level of scratch area which should be revealed to complete.
  final double threshold;

  /// Size of the brush. The bigger it is the faster user can scratch the card.
  final double brushSize;

  /// Determines how accurate the progress should be reported.
  /// Lower accuracy means higher performance.
  final ScratchAccuracy accuracy;

  /// Color used to cover the child widget.
  final Color color;

  /// Path to the local image asset which could be additionally used to cover
  /// the child widget.
  final String imagePath;

  /// Determines how the image should be drawn in case of remaining space
  /// (like contain or cover).
  final BoxFit imageFit;

  /// Callback called when new part of area is revealed (min 0.1% difference).
  final Function(double value) onChange;

  /// Callback called when threshold is reached.
  final Function() onThreshold;
}

class _ScratcherState extends State<Scratcher> {
  Future<ui.Image> imageLoader;
  Offset _lastPosition;

  List<Offset> points = [];
  Set<Offset> checkpoints;
  Set<Offset> checked = {};
  int totalCheckpoints;
  double progress = 0;
  double progressReported = 0;
  bool isFinished = false;

  @override
  void initState() {
    if (widget.imagePath == null) {
      var completer = Completer<ui.Image>()..complete();
      imageLoader = completer.future;
    } else {
      imageLoader = loadImage(widget.imagePath);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: imageLoader,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              addPoint(details.globalPosition);
            },
            onPanUpdate: (details) {
              addPoint(details.globalPosition);
            },
            onPanEnd: (event) => setState(() {
              points.add(null);
            }),
            child: CustomPaint(
              foregroundPainter: ScratchPainter(
                image: snapshot.data,
                imageFit: widget.imageFit,
                points: points,
                brushSize: widget.brushSize,
                color: widget.color,
                onPaint: onPaint,
              ),
              child: widget.child,
            ),
          );
        }

        return Container();
      },
    );
  }

  Future<ui.Image> loadImage(String asset) async {
    var data = await rootBundle.load(asset);
    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    var fi = await codec.getNextFrame();
    return fi.image;
  }

  bool _inCircle(Offset center, Offset point, double radius) {
    var dX = center.dx - point.dx;
    var dY = center.dy - point.dy;
    var multi = dX * dX + dY * dY;
    var distance = sqrt(multi).roundToDouble();

    return distance <= radius;
  }

  void addPoint(Offset globalPosition) {
    if (_lastPosition == globalPosition) {
      return;
    }
    _lastPosition = globalPosition;

    var renderBox = context.findRenderObject() as RenderBox;
    var point = renderBox.globalToLocal(globalPosition);

    setState(() {
      points.add(point);
    });

    if (!checked.contains(point)) {
      checked.add(point);

      var reached = <Offset>{};
      for (var checkpoint in checkpoints) {
        var radius = widget.brushSize / 2;
        if (_inCircle(checkpoint, point, radius)) {
          reached.add(checkpoint);
        }
      }

      checkpoints = checkpoints.difference(reached);
      progress =
          ((totalCheckpoints - checkpoints.length) / totalCheckpoints) * 100;
      if (progress - progressReported >= progressReportStep) {
        progressReported = progress;
        widget.onChange?.call(progress);
      }

      if (!isFinished &&
          widget.threshold != null &&
          progress >= widget.threshold) {
        isFinished = true;
        widget.onThreshold?.call();
      }
    }
  }

  void onPaint(Size size) {
    if (checkpoints == null) {
      var calculated = _calculateCheckpoints(size).toSet();

      checkpoints = calculated;
      totalCheckpoints = calculated.length;
    }
  }

  List<Offset> _calculateCheckpoints(Size size) {
    var accuracy = _getAccuracyValue(widget.accuracy);
    var xOffset = size.width / accuracy;
    var yOffset = size.height / accuracy;

    var points = <Offset>[];
    for (var x = 0; x < accuracy; x++) {
      for (var y = 0; y < accuracy; y++) {
        var point = Offset(
          x * xOffset,
          y * yOffset,
        );
        points.add(point);
      }
    }

    return points;
  }
}
