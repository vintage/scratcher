import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Custom painter object which handles revealing of color/image
class ScratchPainter extends CustomPainter {
  ScratchPainter({
    this.points,
    this.brushSize,
    this.color,
    this.image,
    this.imageFit,
    this.onPaint,
  });

  /// List of revealed points from scratcher
  final List<Offset> points;

  /// Size of the brush used during reveal
  final double brushSize;

  /// Background color of the scratch area
  final Color color;

  /// Path to local image which can be used as scratch area
  final ui.Image image;

  /// Determine how the image should fit the scratch area
  final BoxFit imageFit;

  /// Callback called after each repaint
  final Function(Size) onPaint;

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
      var imageSize = Size(image.width.toDouble(), image.height.toDouble());
      var sizes = applyBoxFit(imageFit, imageSize, size);
      var inputSubrect =
          Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
      var outputSubrect =
          Alignment.center.inscribe(sizes.destination, areaRect);
      canvas.drawImageRect(image, inputSubrect, outputSubrect, Paint());
    }

    for (var i = 0; i < points.length - 1; i++) {
      var current = points[i];
      if (current == null) {
        continue;
      }

      var next = points[i + 1];
      if (next == null) {
        var offsetPoints = <Offset>[
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
