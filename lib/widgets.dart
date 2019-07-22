import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'painter.dart';

const progressReportStep = 0.1;

/// Scratcher widget which covers given child with scratchable overlay
class Scratcher extends StatefulWidget {
  @override
  _ScratcherState createState() => _ScratcherState();

  Scratcher({
    Key key,
    @required this.child,
    this.threshold,
    this.brushSize = 25,
    this.color = Colors.black,
    this.imagePath,
    this.imageFit = BoxFit.cover,
    this.onChange,
    this.onThreshold,
  }) : super(key: key);

  /// Widget to draw under scratch area
  final Widget child;
  /// Percentage level of scratch area which should be revealed
  final double threshold;
  /// Size of the brush used during reveal
  final double brushSize;
  /// Background color of the scratch area
  final Color color;
  /// Path to local image which can be used as scratch area
  final String imagePath;
  /// Determine how the image should fit the scratch area
  final BoxFit imageFit;
  /// Callback called when new part of area is revealed
  final Function(double value) onChange;
  /// Callback called when threshold is reached
  final Function() onThreshold;
}

class _ScratcherState extends State<Scratcher> {
  Future<ui.Image> imageLoader;

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

  void addPoint(Offset globalPosition) {
    var renderBox = context.findRenderObject() as RenderBox;
    var point = renderBox.globalToLocal(globalPosition);

    setState(() {
      points.add(point);
    });

    if (!checked.contains(point)) {
      checked.add(point);

      var reached = <Offset>{};
      for (var checkpoint in checkpoints) {
        var xDiff = (checkpoint.dx - point.dx).abs();
        var yDiff = (checkpoint.dy - point.dy).abs();
        var radius = widget.brushSize / 2;

        if (xDiff < radius && yDiff < radius) {
          reached.add(checkpoint);
        }
      }

      checkpoints = checkpoints.difference(reached);
      progress = (totalCheckpoints - checkpoints.length) / 100;
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
    var xOffset = size.width / 100;
    var yOffset = size.height / 100;

    var points = <Offset>[];
    for (var x = 0; x < 100; x++) {
      for (var y = 0; y < 100; y++) {
        points.add(Offset(
          x * xOffset,
          y * yOffset,
        ));
      }
    }

    return points;
  }
}
