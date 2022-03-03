import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:html' as html;

import 'controller.dart';
import 'painter.dart';

class CanvasView extends StatefulWidget {
  const CanvasView({Key? key, required this.controller}) : super(key: key);

  final CanvasController controller;

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  @override
  void initState() {
    super.initState();

    // Dom Wheel Event
    html.document.body!.addEventListener('wheel', (e) {
      e.preventDefault();
      final event = e as html.WheelEvent;
      final origin = event.offset;
      final controller = widget.controller;
      if (e.ctrlKey == true) {
        double scale = 1;
        if (event.deltaY < 0) {
          scale = 0.1;
        } else {
          scale = -0.1;
        }
        controller.scale(
            scale, Offset(origin.x.toDouble(), origin.y.toDouble()));
      } else {
        controller
            .pan(Offset(-event.deltaX.toDouble(), -event.deltaY.toDouble()));
      }
    }, false);
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
                // TODO: Scroll event with pan / zoom
              }
            },
            child: MouseRegion(
              onHover: (details) {
                widget.controller.mousePosition = details.localPosition;
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
