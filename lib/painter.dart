import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ScratchPainter extends CustomPainter {
  ScratchPainter({
    this.points,
    this.brushSize,
    this.color,
    this.image,
    this.imageFit,
    this.onPaint,
  });

  final List<Offset> points;
  final double brushSize;
  final Color color;
  final ui.Image image;
  final BoxFit imageFit;
  final Function onPaint;

  Paint get mainPaint {
    var paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = false
      ..color = Colors.transparent
      ..strokeWidth = brushSize
      ..blendMode = BlendMode.src;

    return paint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(null, Paint());

    var areaRect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(areaRect, Paint()..color = color);
    if (image != null) {
      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());
      final FittedSizes sizes = applyBoxFit(imageFit, imageSize, size);
      final Rect inputSubrect =
          Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
      final Rect outputSubrect = Alignment.center.inscribe(
          sizes.destination, areaRect);
      canvas.drawImageRect(image, inputSubrect, outputSubrect, Paint());
    }

    for (int i = 0; i < points.length - 1; i++) {
      var current = points[i];
      if (current == null) {
        continue;
      }

      var next = points[i + 1];
      if (next == null) {
        List<Offset> offsetPoints = [
          current,
          Offset(current.dx + 0.1, current.dy + 0.1)
        ];
        canvas.drawPoints(ui.PointMode.points, offsetPoints, mainPaint);
      } else {
        canvas.drawLine(current, next, mainPaint);
      }
    }

    canvas.restore();

    this.onPaint(size);
  }

  @override
  bool shouldRepaint(ScratchPainter oldDelegate) => true;
}
