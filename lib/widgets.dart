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

  /// Medium accuracy, medium performance
  medium,

  /// High accuracy, lower performance.
  high,
}

double _getAccuracyValue(ScratchAccuracy accuracy) {
  switch (accuracy) {
    case ScratchAccuracy.low:
      return 10.0;
    case ScratchAccuracy.medium:
      return 30.0;
    case ScratchAccuracy.high:
      return 100.0;
  }

  return 0;
}

/// Scratcher widget which covers given child with scratchable overlay.
class Scratcher extends StatefulWidget {
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

  @override
  ScratcherState createState() => ScratcherState();
}

class ScratcherState extends State<Scratcher> {
  Future<ui.Image> _imageLoader;
  Offset _lastPosition;

  List<Offset> points = [];
  Set<Offset> checkpoints;
  Set<Offset> checked = {};
  int totalCheckpoints;
  double progress = 0;
  double progressReported = 0;
  bool thresholdReported = false;
  bool isFinished = false;
  bool canScratch = true;
  Duration transitionDuration;

  RenderBox get renderObject {
    return context.findRenderObject() as RenderBox;
  }

  @override
  void initState() {
    if (widget.imagePath == null) {
      var completer = Completer<ui.Image>()..complete();
      _imageLoader = completer.future;
    } else {
      _imageLoader = _loadImage(widget.imagePath);
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _setCheckpoints(renderObject.size));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _imageLoader,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          var paint = CustomPaint(
            foregroundPainter: ScratchPainter(
              image: snapshot.data,
              imageFit: widget.imageFit,
              points: points,
              brushSize: widget.brushSize,
              color: widget.color,
            ),
            child: widget.child,
          );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: canScratch
                ? (details) {
                    _addPoint(details.globalPosition);
                  }
                : null,
            onPanUpdate: canScratch
                ? (details) {
                    _addPoint(details.globalPosition);
                  }
                : null,
            onPanEnd: canScratch
                ? (details) => setState(() {
                      points.add(null);
                    })
                : null,
            child: AnimatedSwitcher(
              duration: transitionDuration == null
                  ? Duration(milliseconds: 0)
                  : transitionDuration,
              child: isFinished ? widget.child : paint,
            ),
          );
        }

        return Container();
      },
    );
  }

  Future<ui.Image> _loadImage(String asset) async {
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

  void _addPoint(Offset globalPosition) {
    // Ignore when same point is reported multiple times in a row
    if (_lastPosition == globalPosition) {
      return;
    }
    _lastPosition = globalPosition;

    var point = renderObject.globalToLocal(globalPosition);

    // Ignore when starting point of new line has been already scratched
    if (points.isNotEmpty && points.contains(point)) {
      if (points.last == null) {
        return;
      } else {
        point = null;
      }
    }

    setState(() {
      points.add(point);
    });

    if (point != null && !checked.contains(point)) {
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

      if (!thresholdReported &&
          widget.threshold != null &&
          progress >= widget.threshold) {
        thresholdReported = true;
        widget.onThreshold?.call();
      }

      if (progress == 100) {
        isFinished = true;
      }
    }
  }

  void _setCheckpoints(Size size) {
    var calculated = _calculateCheckpoints(size).toSet();

    checkpoints = calculated;
    totalCheckpoints = calculated.length;
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

  /// Resets the scratcher state to the initial values.
  void reset({Duration duration}) {
    setState(() {
      transitionDuration = duration;
      isFinished = false;
      canScratch = duration == null ? true : false;

      _lastPosition = null;
      points = [];
      checked = {};
      progress = 0;
      progressReported = 0;
    });

    // Do not allow to scratch during transition
    if (duration != null) {
      Future.delayed(duration, () {
        setState(() {
          canScratch = true;
        });
      });
    }

    _setCheckpoints(renderObject.size);
    widget.onChange?.call(0);
  }

  /// Reveals the whole scratcher, so than only original child is displayed.
  void reveal({Duration duration}) {
    setState(() {
      transitionDuration = duration;
      isFinished = true;
      canScratch = false;
    });

    widget.onChange?.call(100);
  }
}
