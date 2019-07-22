import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:scratcher/scratcher.dart';

void main() {
  test('ScratchPainter has correct paint', () {
    var painter = ScratchPainter(brushSize: 10);
    var paint = painter.mainPaint;

    expect(paint.strokeCap, StrokeCap.round);
    expect(paint.isAntiAlias, false);
    expect(paint.color, Colors.transparent);
    expect(paint.strokeWidth, 10);
    expect(paint.blendMode, BlendMode.src);
  });
}
