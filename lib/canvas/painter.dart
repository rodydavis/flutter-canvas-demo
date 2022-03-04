import 'package:flutter/material.dart';

import 'controller.dart';

class CanvasPainter extends CustomPainter {
  CanvasPainter({
    required this.controller,
    required this.context,
  }) : super(repaint: controller);

  final CanvasController controller;
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Draw background
    drawBackground(canvas, Offset.zero & size);

    canvas.transform(controller.matrix.storage);

    // Draw widgets
    for (final widget in controller.widgets) {
      final offset = widget.rect.topLeft;
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      widget.draw(canvas, widget.rect.size);
      canvas.restore();

      if (controller.selected.contains(widget)) {
        drawOutline(canvas, widget.rect, Colors.red);
      } else if (controller.hovered.contains(widget)) {
        drawOutline(canvas, widget.rect, Colors.black);
      }
    }

    canvas.restore();
  }

  void drawOutline(Canvas canvas, Rect bounds, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(bounds, paint);
  }

  void drawBackground(Canvas canvas, Rect bounds) {
    final transform = controller.matrix;
    final _offset = Offset(transform.entry(0, 3), transform.entry(1, 3));
    final dx =
        _offset.dx == double.infinity || _offset.dx.isNaN ? 0 : _offset.dx;
    final dy =
        _offset.dy == double.infinity || _offset.dy.isNaN ? 0 : _offset.dy;
    final offset = Offset(dx.toDouble(), dy.toDouble());
    final scale = transform.getMaxScaleOnAxis();
    final colors = Theme.of(context).colorScheme;

    canvas.save();
    final backgroundPaint = Paint()
      ..color = colors.background
      ..style = PaintingStyle.fill;
    canvas.drawRect(bounds, backgroundPaint);

    // Draw infinite dotted grid
    final gridSize = 20.0 * scale;
    final gridOffsetDx = offset.dx.round() % gridSize;
    final gridOffsetDy = offset.dy.round() % gridSize;

    final gridPaint = Paint()
      ..color = colors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / scale;

    for (var x = gridOffsetDx; x < bounds.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, bounds.height), gridPaint);
    }

    for (var y = gridOffsetDy; y < bounds.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(bounds.width, y), gridPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
