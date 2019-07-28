import 'package:flutter_web_ui/ui.dart' as ui;

import 'package:flutter_web/material.dart';

/// Custom painter object which handles revealing of color/image
class ScratchPainter extends CustomPainter {
  ScratchPainter({
    this.points,
    this.brushSize,
    this.color,
    this.image,
    this.imageFit,
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

  Paint get mainPaint {
    var paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.transparent
      ..strokeWidth = brushSize
      ..blendMode = BlendMode.src
      ..style = PaintingStyle.stroke;

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

    var path = Path();
    var isStarted = false;
    for (var point in points) {
      if (point == null) {
        canvas.drawPath(path, mainPaint);
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
      ..drawPath(path, mainPaint)
      ..restore();
  }

  @override
  bool shouldRepaint(ScratchPainter oldDelegate) => true;
}
