import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/themes/app_theme.dart';
import '../../view_models/home_view_model.dart';
import 'setup_reward_pill.dart';

class SetupChecklist extends StatelessWidget {
  const SetupChecklist({
    super.key,
    required this.viewModel,
    required this.onOpen,
  });

  final HomeViewModel viewModel;
  final ValueChanged<SetupTask> onOpen;

  static const labels = {
    SetupTask.language: 'Language',
    SetupTask.age: 'Your age',
    SetupTask.classLevel: 'Your class',
    SetupTask.board: 'Your board',
  };

  @override
  Widget build(BuildContext context) {
    final done = viewModel.doneCount;
    final total = SetupTask.values.length;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.tintCream,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        border: Border.all(
          color: context.palette.edge,
          width: AppKeycap.borderWidth,
        ),
        boxShadow: [
          BoxShadow(color: context.palette.edge, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Set up your dashboard',
                    style: AppTextStyles.display.copyWith(
                      fontSize: 18,
                      color: context.palette.text,
                    ),
                  ),
                ),
                SetupRewardPill(
                  label:
                      '${done * HomeViewModel.xpPerTask} / ${total * HomeViewModel.xpPerTask} XP',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(end: done / total),
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                borderRadius: BorderRadius.circular(AppRadius.full),
                color: AppColors.selected,
                backgroundColor: context.palette.surface,
              ),
            ),
            const SizedBox(height: 4),
            for (final task in SetupTask.values)
              _ChecklistItem(
                label: labels[task]!,
                isDone: viewModel.isDone(task),
                onTap: () => onOpen(task),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatefulWidget {
  const _ChecklistItem({
    required this.label,
    required this.isDone,
    required this.onTap,
  });

  final String label;
  final bool isDone;
  final VoidCallback onTap;

  @override
  State<_ChecklistItem> createState() => _ChecklistItemState();
}

class _ChecklistItemState extends State<_ChecklistItem>
    with SingleTickerProviderStateMixin {
  late final _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didUpdateWidget(_ChecklistItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDone && !oldWidget.isDone) {
      HapticFeedback.lightImpact();
      _burst.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.isDone;
    return InkWell(
      onTap: done ? null : widget.onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 20,
              child: CustomPaint(
                painter: _BurstPainter(_burst),
                child: _Tick(isDone: done, pop: _burst),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: AppTextStyles.labelStrong.copyWith(
                  color: done
                      ? context.palette.textMuted
                      : context.palette.text,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Text(
              done
                  ? '✓ ${HomeViewModel.xpPerTask} XP'
                  : '+${HomeViewModel.xpPerTask} XP',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: done ? context.palette.success : AppColors.selectedInk,
              ),
            ),
            if (!done) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: context.palette.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick({required this.isDone, required this.pop});

  final bool isDone;
  final Animation<double> pop;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pop.drive(
        TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1, end: 1.4),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.4, end: 1),
            weight: 70,
          ),
        ]),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDone ? context.palette.success : context.palette.surface,
          border: Border.all(
            color: isDone ? context.palette.success : context.palette.edge,
            width: AppKeycap.borderWidth,
          ),
        ),
        child: isDone
            ? const Icon(
                Icons.check_rounded,
                size: 14,
                color: AppColors.onPrimary,
              )
            : null,
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  static const _colors = [
    AppColors.selected,
    AppColors.primary,
    AppColors.success,
    AppColors.streak,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t == 0 || t == 1) return;
    final center = size.center(Offset.zero);
    for (var i = 0; i < 10; i++) {
      final angle = i * 2 * math.pi / 10;
      final distance = 6 + 22 * Curves.easeOutCubic.transform(t);
      final spot = center + Offset(math.cos(angle), math.sin(angle)) * distance;
      canvas.drawCircle(
        spot,
        3 * (1 - t),
        Paint()..color = _colors[i % _colors.length].withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => false;
}
