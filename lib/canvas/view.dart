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
    return SizedBox.expand(
      child: ClipRect(
        clipBehavior: Clip.antiAlias,
        child: Focus(
          autofocus: true,
          onKey: (node, event) {
            if (event is RawKeyDownEvent) {
              widget.controller.shiftPressed =
                  event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                      event.logicalKey == LogicalKeyboardKey.shiftRight;
              widget.controller.controlPressed =
                  event.logicalKey == LogicalKeyboardKey.controlLeft ||
                      event.logicalKey == LogicalKeyboardKey.controlRight;
              widget.controller.spaceBarPressed =
                  event.logicalKey == LogicalKeyboardKey.space;
            } else {
              widget.controller.controlPressed = false;
              widget.controller.spaceBarPressed = false;
              widget.controller.shiftPressed = false;
            }
            return KeyEventResult.ignored;
          },
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                // TODO: Scale and Pan at the same time
                if (widget.controller.controlPressed) {
                  double zoomDelta = -event.scrollDelta.dy / 300;
                  final amount = zoomDelta > 0 ? 1.1 : 0.9;
                  widget.controller
                      .scale(amount, widget.controller.mousePosition);
                } else {
                  widget.controller.pan(-event.scrollDelta);
                }
                widget.controller.update();
              }
            },
            onPointerDown: (event) {
              widget.controller.addPointer(event.pointer, event.position);
            },
            onPointerMove: (event) {
              widget.controller.updatePointer(event.pointer, event.position);
            },
            onPointerUp: (event) {
              widget.controller.removePointer(event.pointer);
            },
            child: MouseRegion(
              cursor: _cursor,
              onHover: (details) {
                widget.controller
                    .updateMouse(details.localPosition, details.delta);
              },
              child: CustomPaint(
                painter: CanvasPainter(
                  controller: widget.controller,
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
