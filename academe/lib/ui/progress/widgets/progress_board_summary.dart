part of 'progress_board.dart';

class _SummaryPane extends StatelessWidget {
  const _SummaryPane({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatKey(
                label: 'Subjects this week',
                value: '${summary.bySubject.length}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatKey(
                label: 'Completed',
                value: '${summary.lessonsFinishedThisWeek}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _GradeKey(summary: summary),
      ],
    );
  }
}

class _StatKey extends StatelessWidget {
  const _StatKey({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return KeycapSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.palette.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.display.copyWith(
              fontSize: 36,
              height: 0.9,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeKey extends StatelessWidget {
  const _GradeKey({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final hasGrade = summary.overallGrade != null;
    return KeycapSurface(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall grade',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.palette.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.gradeLabel,
                  style: AppTextStyles.display.copyWith(
                    fontSize: 36,
                    height: 0.9,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 78,
            child: Column(
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: CustomPaint(
                    painter: _GradeRingPainter(
                      fraction: summary.gradeFraction,
                      track: context.palette.surfaceRaised,
                      fill: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasGrade ? 'Keep it up' : 'Start your journey',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeRingPainter extends CustomPainter {
  const _GradeRingPainter({
    required this.fraction,
    required this.track,
    required this.fill,
  });

  final double fraction;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 2;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    if (fraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708,
        6.2832 * fraction,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GradeRingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.track != track ||
      oldDelegate.fill != fill;
}
