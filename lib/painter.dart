import 'dart:ui' as ui;

import 'package:flutter/material.dart';

typedef _DrawFunction(Size size);

/// Custom painter object which handles revealing of color/image
class ScratchPainter extends CustomPainter {
  ScratchPainter({
    this.points,
    this.brushSize,
    this.color,
    this.image,
    this.imageFit,
    this.onDraw,
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

  /// Callback called each time the painter is redraw
  final _DrawFunction onDraw;

  Paint get _mainPaint {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.transparent
      ..strokeWidth = brushSize
      ..blendMode = BlendMode.src
      ..style = PaintingStyle.stroke;

    return paint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    onDraw(size);

    canvas.saveLayer(null, Paint());

    final areaRect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(areaRect, Paint()..color = color);
    if (image != null) {
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final sizes = applyBoxFit(imageFit, imageSize, size);
      final inputSubrect =
          Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
      final outputSubrect =
          Alignment.center.inscribe(sizes.destination, areaRect);
      canvas.drawImageRect(image, inputSubrect, outputSubrect, Paint());
    }

    var path = Path();
    var isStarted = false;
    for (final point in points) {
      if (point == null) {
        canvas.drawPath(path, _mainPaint);
        path = Path();
        isStarted = false;
      } else {
        if (!isStarted) {
          isStarted = true;
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
    }

    canvas
      ..drawPath(path, _mainPaint)
      ..restore();
  }

  @override
  bool shouldRepaint(ScratchPainter oldDelegate) => true;
}
