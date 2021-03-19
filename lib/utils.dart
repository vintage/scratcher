import 'package:flutter/material.dart';

class ScratchPoint {
  ScratchPoint(this.position, this.size);

  // Null position is dedicated for point which closes the continuous drawing
  final Offset? position;
  final double size;
}
