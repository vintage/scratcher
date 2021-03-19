import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:scratcher/utils.dart';

/// Custom painter object which handles revealing of color/image
class ScratchPainter extends CustomPainter {
  ScratchPainter({
    required this.points,
    required this.color,
    required this.onDraw,
    this.image,
    this.imageFit,
  });

  /// List of revealed points from scratcher
  final List<ScratchPoint?> points;

  /// Background color of the scratch area
  final Color color;

  /// Callback called each time the painter is redraw
  final void Function(Size) onDraw;

  /// Path to local image which can be used as scratch area
  final ui.Image? image;

  /// Determine how the image should fit the scratch area
  final BoxFit? imageFit;

  Paint _getMainPaint(double strokeWidth) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.transparent
      ..strokeWidth = strokeWidth
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
    if (image != null && imageFit != null) {
      // TODO: why the ! are needed here, as check against null been performed?
      final imageSize = Size(image!.width.toDouble(), image!.height.toDouble());
      final sizes = applyBoxFit(imageFit!, imageSize, size);
      final inputSubrect =
          Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
      final outputSubrect =
          Alignment.center.inscribe(sizes.destination, areaRect);

      canvas.drawImageRect(image!, inputSubrect, outputSubrect, Paint());
    }

    var path = Path();
    var isStarted = false;
    ScratchPoint? previousPoint;

    for (final point in points) {
      if (point == null) {
        if (previousPoint != null) {
          canvas.drawPath(path, _getMainPaint(previousPoint.size));
        }

        path = Path();
        isStarted = false;
      } else {
        final position = point.position;
        if (!isStarted) {
          isStarted = true;
          path.moveTo(position!.dx, position.dy);
        } else {
          path.lineTo(position!.dx, position.dy);
        }
      }

      previousPoint = point;
    }

    if (previousPoint != null) {
      canvas.drawPath(path, _getMainPaint(previousPoint.size));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(ScratchPainter oldDelegate) => true;
}
