import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controller.dart';
import 'painter.dart';

class CanvasView extends StatelessWidget {
  const CanvasView({Key? key, required this.controller}) : super(key: key);

  final CanvasController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ClipRect(
        clipBehavior: Clip.antiAlias,
        child: Focus(
          autofocus: true,
          onKey: (node, event) {
            if (event is RawKeyDownEvent) {
              controller.shiftPressed =
                  event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                      event.logicalKey == LogicalKeyboardKey.shiftRight;
              controller.controlPressed =
                  event.logicalKey == LogicalKeyboardKey.controlLeft ||
                      event.logicalKey == LogicalKeyboardKey.controlRight;
              controller.spaceBarPressed =
                  event.logicalKey == LogicalKeyboardKey.space;
            } else {
              controller.controlPressed = false;
              controller.spaceBarPressed = false;
              controller.shiftPressed = false;
            }
            return KeyEventResult.ignored;
          },
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                GestureBinding.instance.pointerSignalResolver.register(event,
                    (event) {
                  if (event is PointerScrollEvent) {
                    // TODO: Scale and Pan at the same time
                    if (controller.shiftPressed) {
                      double zoomDelta = (-event.scrollDelta.dy / 300);
                      controller.scale(zoomDelta, controller.mousePosition);
                    } else {
                      controller.pan(-event.scrollDelta);
                    }
                    controller.update();
                  }
                });
              }
            },
            child: MouseRegion(
              onHover: (details) {
                controller.mousePosition = details.localPosition;
              },
              child: CustomPaint(
                painter: CanvasPainter(
                  controller: controller,
                  context: context,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
