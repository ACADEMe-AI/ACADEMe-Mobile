import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/app_theme.dart';

class NumberWheel<T> extends StatefulWidget {
  const NumberWheel({
    super.key,
    required this.values,
    required this.value,
    required this.label,
    required this.onChanged,
    this.width = 160,
    this.height = 220,
    this.semanticsLabel,
  });

  final List<T> values;
  final T value;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;
  final double width;
  final double height;
  final String? semanticsLabel;

  static const itemExtent = 48.0;

  @override
  State<NumberWheel<T>> createState() => _NumberWheelState<T>();
}

class _NumberWheelState<T> extends State<NumberWheel<T>> {
  late final _wheel = FixedExtentScrollController(
    initialItem: widget.values
        .indexOf(widget.value)
        .clamp(0, widget.values.length - 1),
  );

  @override
  void dispose() {
    _wheel.dispose();
    super.dispose();
  }

  void _onSelected(int index) {
    HapticFeedback.selectionClick();
    widget.onChanged(widget.values[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel,
      value: widget.label(widget.value),
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const _SelectionBand(),
            ListWheelScrollView.useDelegate(
              controller: _wheel,
              itemExtent: NumberWheel.itemExtent,
              diameterRatio: 1.6,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: _onSelected,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.values.length,
                builder: (context, index) {
                  final isSelected = widget.values[index] == widget.value;
                  return Center(
                    child: Text(
                      widget.label(widget.values[index]),
                      style: AppTextStyles.display.copyWith(
                        fontSize: isSelected ? 32 : 22,
                        color: isSelected
                            ? context.palette.text
                            : context.palette.textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionBand extends StatelessWidget {
  const _SelectionBand();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: NumberWheel.itemExtent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(color: context.palette.border, width: 2),
          ),
        ),
      ),
    );
  }
}
