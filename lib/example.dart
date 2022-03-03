import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_canvas_demo/canvas/widget.dart';

import 'canvas/controller.dart';
import 'canvas/view.dart';

class CanvasExample extends StatelessWidget {
  const CanvasExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = CanvasController(widgets: []);
    // Add random shapes to the canvas.
    final size = MediaQuery.of(context).size;
    for (var i = 0; i < 10; i++) {
      final double dx = Random().nextDouble() * size.width;
      final double dy = Random().nextDouble() * size.height;
      final randomColor = Color.fromARGB(
        255,
        Random().nextInt(255),
        Random().nextInt(255),
        Random().nextInt(255),
      );
      controller.widgets.add(InlineCanvasWidget(
        rect: Rect.fromLTWH(dx, dy, 100, 100),
        paint: (ctx, size) {
          ctx.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Paint()..color = randomColor,
          );
        },
      ));
    }
    return CanvasView(
      controller: controller,
    );
  }
}
