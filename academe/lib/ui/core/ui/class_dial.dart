import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/profile.dart';
import '../themes/app_theme.dart';

class ClassDial extends StatelessWidget {
  const ClassDial({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const size = 232.0;
  static const _numberSize = 40.0;
  static const _radius = 92.0;
  static final _classes = [
    for (var c = Profile.firstClass; c <= Profile.lastClass; c++) c,
  ];

  static double _angleOf(int index) =>
      -math.pi / 2 + index * 2 * math.pi / _classes.length;

  void _pick(Offset position) {
    final vector = position - const Offset(size / 2, size / 2);
    if (vector.distance < 24) return;
    var angle = math.atan2(vector.dy, vector.dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    final step = 2 * math.pi / _classes.length;
    final index = (angle / step).round() % _classes.length;
    final picked = _classes[index];
    if (picked == value) return;
    HapticFeedback.selectionClick();
    onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Class $value',
      child: GestureDetector(
        onTapUp: (details) => _pick(details.localPosition),
        onPanUpdate: (details) => _pick(details.localPosition),
        child: SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.palette.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.palette.edge,
                width: AppKeycap.borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.palette.edge,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                for (final (index, classLevel) in _classes.indexed)
                  Positioned(
                    left:
                        size / 2 +
                        _radius * math.cos(_angleOf(index)) -
                        _numberSize / 2,
                    top:
                        size / 2 +
                        _radius * math.sin(_angleOf(index)) -
                        _numberSize / 2,
                    child: _DialNumber(
                      classLevel: classLevel,
                      isSelected: classLevel == value,
                    ),
                  ),
                Center(
                  child: SizedBox.square(
                    dimension: 112,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$value',
                            style: AppTextStyles.display.copyWith(
                              fontSize: 48,
                              height: 1,
                              color: AppColors.onPrimary,
                            ),
                          ),
                          Text(
                            'CLASS',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialNumber extends StatelessWidget {
  const _DialNumber({required this.classLevel, required this.isSelected});

  final int classLevel;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: ClassDial._numberSize,
      height: ClassDial._numberSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.selected : context.palette.surface,
        border: Border.all(
          color: isSelected ? context.palette.edge : context.palette.surface,
          width: AppKeycap.borderWidth,
        ),
      ),
      child: Text(
        '$classLevel',
        style: AppTextStyles.display.copyWith(
          fontSize: 20,
          color: context.palette.text,
        ),
      ),
    );
  }
}
