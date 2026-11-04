import 'package:flutter/animation.dart';

class Keyframe {
  const Keyframe(this.ms, this.value, [this.curve = Curves.linear]);

  final double ms;
  final double value;
  final Curve curve;
}

double sampleKeyframes(List<Keyframe> keys, double ms) {
  for (var i = 0; i < keys.length - 1; i++) {
    final from = keys[i];
    final to = keys[i + 1];
    if (ms <= to.ms) {
      final span = to.ms - from.ms;
      final progress = span == 0
          ? 1.0
          : ((ms - from.ms) / span).clamp(0.0, 1.0);
      return from.value +
          (to.value - from.value) * to.curve.transform(progress);
    }
  }
  return keys.last.value;
}
