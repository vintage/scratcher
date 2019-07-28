import 'dart:async';
import 'dart:math';
import 'package:flutter_web_ui/ui.dart' as ui;

import 'package:flutter_web/material.dart';
import 'package:flutter_web/services.dart';

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
    this.revealDuration,
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

  /// Fade out animation duration for unscratched area when threshold reached.
  /// When not defined - the remaining area won't disappear automatically.
  final Duration revealDuration;

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
  Future<ui.Image> _imageLoader;
  Offset _lastPosition;

  List<Offset> points = [];
  Set<Offset> checkpoints;
  Set<Offset> checked = {};
  int totalCheckpoints;
  double progress = 0;
  double progressReported = 0;
  bool isFinished = false;

  RenderBox get renderObject {
    return context.findRenderObject() as RenderBox;
  }

  @override
  void initState() {
    if (widget.imagePath == null) {
      var completer = Completer<ui.Image>()..complete();
      _imageLoader = completer.future;
    } else {
      _imageLoader = loadImage(widget.imagePath);
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) => setCheckpoints(renderObject.size));

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
          var canScratch = !(isFinished && widget.revealDuration != null);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: canScratch
                ? (details) {
                    addPoint(details.globalPosition);
                  }
                : null,
            onPanUpdate: canScratch
                ? (details) {
                    addPoint(details.globalPosition);
                  }
                : null,
            onPanEnd: canScratch
                ? (details) => setState(() {
                      points.add(null);
                    })
                : null,
            child: widget.revealDuration == null
                ? paint
                : AnimatedSwitcher(
                    duration: widget.revealDuration,
                    child: isFinished ? widget.child : paint,
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
    // Ignore when same point is reported multiple times in a row
    if (_lastPosition == globalPosition) {
      return;
    }
    _lastPosition = globalPosition;

    var point = renderObject.globalToLocal(globalPosition);

    // Ignore when starting point of new line has been already scratched
    if (points.isNotEmpty && points.last == null && points.contains(point)) {
      return;
    }

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

  void setCheckpoints(Size size) {
    var calculated = calculateCheckpoints(size).toSet();

    checkpoints = calculated;
    totalCheckpoints = calculated.length;
  }

  List<Offset> calculateCheckpoints(Size size) {
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
