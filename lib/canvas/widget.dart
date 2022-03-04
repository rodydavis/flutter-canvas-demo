import 'package:flutter/material.dart';

abstract class CanvasWidget {
  Rect rect;

  CanvasWidget(this.rect);

  void draw(Canvas canvas, Size size);
}

class InlineCanvasWidget extends CanvasWidget {
  InlineCanvasWidget({
    required Rect rect,
    required this.paint,
  }) : super(rect);

  final void Function(Canvas canvas, Size size) paint;

  @override
  void draw(Canvas canvas, Size size) {
    paint(canvas, size);
  }
}
