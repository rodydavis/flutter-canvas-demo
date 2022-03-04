import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controller.dart';
import 'painter.dart';

class CanvasView extends StatefulWidget {
  const CanvasView({Key? key, required this.controller}) : super(key: key);

  final CanvasController controller;

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  MouseCursor _cursor = MouseCursor.defer;

  @override
  void initState() {
    super.initState();
    _cursor = widget.controller.getCursor();
    widget.controller.addListener(() => setState(() {
          _cursor = widget.controller.getCursor();
        }));
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
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

              // Check for arrow keys
              const double amount = 4;
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                controller.pan(Offset(-amount, 0));
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                controller.pan(Offset(amount, 0));
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                controller.pan(Offset(0, -amount));
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                controller.pan(Offset(0, amount));
              }
              // Check for zoom in/out
              else if (event.logicalKey == LogicalKeyboardKey.equal) {
                controller.scale(1.1, controller.mousePosition);
              } else if (event.logicalKey == LogicalKeyboardKey.minus) {
                controller.scale(0.9, controller.mousePosition);
              }
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
                // TODO: Scale and Pan at the same time
                if (controller.controlPressed) {
                  double zoomDelta = -event.scrollDelta.dy / 300;
                  final amount = zoomDelta > 0 ? 1.1 : 0.9;
                  controller.scale(amount, controller.mousePosition);
                } else {
                  controller.pan(-event.scrollDelta);
                }
                controller.update();
              }
            },
            onPointerDown: (event) {
              controller.addPointer(event.pointer, event.position);
            },
            onPointerMove: (event) {
              controller.updatePointer(event.pointer, event.position);
            },
            onPointerUp: (event) {
              controller.removePointer(event.pointer);
            },
            child: MouseRegion(
              cursor: _cursor,
              onHover: (details) {
                controller.updateMouse(details.localPosition, details.delta);
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
