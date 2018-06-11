import 'package:flutter/material.dart';

class GalleryTextScaleValue {
  const GalleryTextScaleValue(this.scale, this.label);

  final double scale;
  final String label;

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    return scale == other.scale && label == other.label;
  }

  @override
  int get hashCode => hashValues(scale, label);

  @override
  String toString() {
    return '$runtimeType($label)';
  }
}

const kAllGalleryTextScaleValues = <GalleryTextScaleValue>[
  GalleryTextScaleValue(null, 'System Default'),
  GalleryTextScaleValue(0.8, 'Small'),
  GalleryTextScaleValue(1.0, 'Normal'),
  GalleryTextScaleValue(1.3, 'Large'),
  GalleryTextScaleValue(2.0, 'Huge'),
];
