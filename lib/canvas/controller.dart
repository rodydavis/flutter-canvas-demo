import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
// import 'package:matrix4_transform/matrix4_transform.dart';

import 'widget.dart';

class CanvasController extends ChangeNotifier {
  CanvasController({required this.widgets});

  List<CanvasWidget> widgets;
  double minScale = 0.1;
  double maxScale = 10;
  double currentScale = 1;
  Offset currentOffset = Offset.zero;
  Offset mousePosition = Offset.zero;
  bool shiftPressed = false;
  bool spaceBarPressed = false;
  bool controlPressed = false;
  bool middleClick = false;

  Matrix4 matrix = Matrix4.identity();

  pan(Offset delta) {
    currentOffset += delta;
    // debugPrint('pan $delta $currentOffset');
    matrix.translate(delta.dx / currentScale, delta.dy / currentScale);
    update();
  }

  scale(double delta, [Offset? focalPoint]) {
    final amount = delta > 0 ? 1.1 : 0.9;
    currentScale *= amount;
    // debugPrint('scale $delta $focalPoint $currentScale');
    if (currentScale < minScale || currentScale > maxScale) {
      return;
    }
    final fp = globalToLocal(focalPoint ?? mousePosition, matrix);
    if (focalPoint != null) matrix.translate(fp.dx, fp.dy);
    matrix.setEntry(0, 0, currentScale);
    matrix.setEntry(1, 1, currentScale);
    // matrix.scale(amount, amount);
    if (focalPoint != null) matrix.translate(-fp.dx, -fp.dy);
    update();
  }

  update() {
    notifyListeners();
  }
}

Offset globalToLocal(Offset point, Matrix4 transform) {
  final matrix = transform.clone();
  final double det = matrix.invert();
  if (det == 0.0) return Offset.zero;
  final n = Vector3(0.0, 0.0, 1.0);
  final i = matrix.perspectiveTransform(Vector3(0.0, 0.0, 0.0));
  final d = matrix.perspectiveTransform(Vector3(0.0, 0.0, 1.0)) - i;
  final s = matrix.perspectiveTransform(Vector3(point.dx, point.dy, 0.0));
  final p = s - d * (n.dot(s) / n.dot(d));
  return Offset(p.x, p.y);
}

Rect globalRectToLocalRect(Rect rect, Matrix4 transform) {
  final topLeft = globalToLocal(rect.topLeft, transform);
  final bottomRight = globalToLocal(rect.bottomRight, transform);
  return Rect.fromPoints(topLeft, bottomRight);
}
