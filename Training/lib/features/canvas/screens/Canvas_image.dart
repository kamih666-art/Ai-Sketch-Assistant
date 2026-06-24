import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CanvasImageElement {
  final String id;
  ui.Image image;
  Offset position;
  double scale;
  double rotation;
  Rect bounds;
  bool isSelected;

  CanvasImageElement({
    required this.id,
    required this.image,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    required this.bounds,
    this.isSelected = false,
  });

  Rect getRect() {
    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final scaledWidth = imageSize.width * scale;
    final scaledHeight = imageSize.height * scale;

    return Rect.fromCenter(
      center: position,
      width: scaledWidth,
      height: scaledHeight,
    );
  }

  bool containsPoint(Offset point) {
    return getRect().contains(point);
  }

  void updateBounds() {
    final rect = getRect();
    bounds = rect;
  }

  CanvasImageElement copyWith({
    String? id,
    ui.Image? image,
    Offset? position,
    double? scale,
    double? rotation,
    Rect? bounds,
    bool? isSelected,
  }) {
    return CanvasImageElement(
      id: id ?? this.id,
      image: image ?? this.image,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      bounds: bounds ?? this.bounds,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}