import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'painter.dart';

const PROGRESS_REPORT_STEP = 0.1;

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

  final Widget child;
  final double threshold;
  final double brushSize;
  final Color color;
  final String imagePath;
  final BoxFit imageFit;
  final Function(double value) onChange;
  final Function() onThreshold;
}

class _ScratcherState extends State<Scratcher> {
  Future<ui.Image> imageLoader;

  List<Offset> points = [];
  Set<Offset> checkpoints;
  Set<Offset> checked = Set();
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
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  void addPoint(Offset globalPosition) {
    RenderBox renderBox = context.findRenderObject();
    Offset point = renderBox.globalToLocal(globalPosition);

    setState(() {
      points.add(point);
    });

    if (!checked.contains(point)) {
      checked.add(point);

      Set<Offset> reached = Set();
      checkpoints.forEach((checkpoint) {
        var xDiff = (checkpoint.dx - point.dx).abs();
        var yDiff = (checkpoint.dy - point.dy).abs();
        var radius = widget.brushSize / 2;

        if (xDiff < radius && yDiff < radius) {
          reached.add(checkpoint);
        }
      });

      checkpoints = checkpoints.difference(reached);
      progress = (totalCheckpoints - checkpoints.length) / 100;
      if (progress - progressReported >= PROGRESS_REPORT_STEP) {
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
    double xOffset = size.width / 100;
    double yOffset = size.height / 100;

    List<Offset> points = [];
    for (int x = 0; x < 100; x++) {
      for (int y = 0; y < 100; y++) {
        points.add(Offset(
          x * xOffset,
          y * yOffset,
        ));
      }
    }

    return points;
  }
}
