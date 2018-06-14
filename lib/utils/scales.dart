import 'package:flutter/material.dart';

class TextScaleValue {
  const TextScaleValue(this.scale, this.label);

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

const kAllTextScaleValues = <TextScaleValue>[
  TextScaleValue(null, 'System Default'),
  TextScaleValue(0.8, 'Small'),
  TextScaleValue(1.0, 'Normal'),
  TextScaleValue(1.3, 'Large'),
  TextScaleValue(2.0, 'Huge'),
];
