import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
// import 'package:matrix4_transform/matrix4_transform.dart';

import 'widget.dart';

class CanvasController extends ChangeNotifier {
  CanvasController({required this.widgets});

  List<CanvasWidget> widgets;
  List<CanvasWidget> selected = [];
  List<CanvasWidget> hovered = [];
  double minScale = 0.2;
  double maxScale = 10;
  double currentScale = 1;
  Offset currentOffset = Offset.zero;
  Offset mousePosition = Offset.zero;
  bool shiftPressed = false;
  bool spaceBarPressed = false;
  bool controlPressed = false;
  bool middleClick = false;
  bool mouseDown = false;
  Matrix4 matrix = Matrix4.identity();
  Map<int, Offset> pointers = {};

  pan(Offset delta) {
    currentOffset += delta;
    matrix.translate(delta.dx / currentScale, delta.dy / currentScale);
    update();
  }

  scale(double delta, [Offset? focalPoint]) {
    if (delta.isNaN) return;
    final amount = delta * currentScale;
    if (amount < minScale || amount > maxScale) return;
    currentScale = amount;
    if (focalPoint != null) {
      final point = toLocalOffset(focalPoint);
      matrix.translate(point.dx, point.dy);
      matrix.scale(delta, delta);
      matrix.translate(-point.dx, -point.dy);
    } else {
      matrix.scale(delta, delta);
    }
    update();
  }

  move(Offset delta) {
    for (final item in widgets) {
      if (selected.contains(item)) {
        final panDelta = delta / currentScale;
        item.rect = item.rect.translate(panDelta.dx, panDelta.dy);
      }
    }
    update();
  }

  toLocalOffset(Offset point) {
    return matrix.toLocalOffset(point);
  }

  addPointer(int id, Offset position) {
    pointers[id] = position;
    mouseDown = true;
    if (pointers.length == 1) {
      final selection = select(position);
      selected = selection.take(1).toList();
    }
    update();
  }

  removePointer(int id) {
    pointers.remove(id);
    mouseDown = pointers.isNotEmpty;
    update();
  }

  List<CanvasWidget> select(Offset offset) {
    final revered = widgets.reversed.toList();
    final point = toLocalOffset(offset);
    final List<CanvasWidget> items = [];

    for (final item in revered) {
      if (item.rect.contains(point)) {
        items.add(item);
      }
    }

    return items;
  }

  updateMouse(Offset position, Offset delta) {
    mousePosition = position;
    hovered = select(position);
    update();
  }

  updatePointer(int id, Offset position) {
    final oldPointers = {...pointers};
    pointers[id] = position;

    final gestureEvent = pointers.length > 1;
    final oldKeys = oldPointers.keys.toList();
    final newKeys = pointers.keys.toList();
    final oldPoint1 = oldPointers[oldKeys[0]]!;
    final newPoint1 = pointers[newKeys[0]]!;

    if (gestureEvent) {
      final oldPoint2 = oldPointers[oldKeys[1]]!;
      final newPoint2 = pointers[newKeys[1]]!;

      // 2 pointers - scale
      if (oldPointers.length == 2) {
        // Get the center of the two touches
        final oldMidPoint = (oldPoint1 + oldPoint2) / 2;
        final newMidPoint = (newPoint1 + newPoint2) / 2;

        // Get the distance between the two touches
        final oldDistance = oldPoint1.dx - oldPoint2.dx;
        final newDistance = newPoint1.dx - newPoint2.dx;

        // Get the scale factor
        final scaleFactor = newDistance / oldDistance;

        // Scale at the center of the two touches
        scale(scaleFactor, newMidPoint);

        if (newMidPoint != oldMidPoint) {
          final delta = newMidPoint - oldMidPoint;
          pan(delta);
        }
      }

      // 3 pointers - pan
      if (oldPointers.length == 3) {
        final oldPoint3 = oldPointers[oldKeys[2]]!;
        final newPoint3 = pointers[newKeys[2]]!;

        // Get the center of the three touches
        final oldMin = Offset(
          min(oldPoint1.dx, min(oldPoint2.dx, oldPoint3.dx)),
          min(oldPoint1.dy, min(oldPoint2.dy, oldPoint3.dy)),
        );
        final newMin = Offset(
          min(newPoint1.dx, min(newPoint2.dx, newPoint3.dx)),
          min(newPoint1.dy, min(newPoint2.dy, newPoint3.dy)),
        );
        final delta = newMin - oldMin;
        pan(delta);
      }
    } else {
      if (mouseDown) {
        final oldKeys = oldPointers.keys.toList();
        final newKeys = pointers.keys.toList();
        final oldPoint1 = oldPointers[oldKeys[0]]!;
        final newPoint1 = pointers[newKeys[0]]!;
        final delta = newPoint1 - oldPoint1;
        if (spaceBarPressed) {
          pan(delta);
        } else {
          move(delta);
        }
      }
    }

    update();
  }

  MouseCursor getCursor() {
    SystemMouseCursor cursor = SystemMouseCursors.basic;
    if (spaceBarPressed) {
      cursor = SystemMouseCursors.grab;
    } else if (hovered.isNotEmpty &&
        hovered.isNotEmpty &&
        selected.isNotEmpty &&
        hovered[0] == selected[0]) {
      cursor = SystemMouseCursors.move;
    }
    return cursor;
  }

  update() {
    notifyListeners();
  }
}

extension MatrixUtils on Matrix4 {
  Offset toLocalOffset(Offset point) {
    final matrix = clone();
    final double det = matrix.invert();
    if (det == 0.0) return Offset.zero;
    final n = Vector3(0.0, 0.0, 1.0);
    final i = matrix.perspectiveTransform(Vector3(0.0, 0.0, 0.0));
    final d = matrix.perspectiveTransform(Vector3(0.0, 0.0, 1.0)) - i;
    final s = matrix.perspectiveTransform(Vector3(point.dx, point.dy, 0.0));
    final p = s - d * (n.dot(s) / n.dot(d));
    return Offset(p.x, p.y);
  }

  Rect toLocalRect(Rect rect) {
    final topLeft = toLocalOffset(rect.topLeft);
    final bottomRight = toLocalOffset(rect.bottomRight);
    return Rect.fromPoints(topLeft, bottomRight);
  }
}
