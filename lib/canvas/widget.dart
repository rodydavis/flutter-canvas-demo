import 'package:flutter/material.dart';

abstract class CanvasWidget {
  Rect get rect;
  void draw(Canvas canvas, Size size);
}

class InlineCanvasWidget extends CanvasWidget {
  InlineCanvasWidget({
    required this.rect,
    required this.paint,
  });

  @override
  final Rect rect;

  final void Function(Canvas canvas, Size size) paint;

  @override
  void draw(Canvas canvas, Size size) {
    paint(canvas, size);
  }
}
