import 'package:flutter/material.dart';

import '../../../domain/models/subject.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/subject_icons.dart';

class SubjectPills extends StatelessWidget {
  const SubjectPills({
    super.key,
    required this.subjects,
    required this.isPicked,
    required this.onToggle,
  });

  final List<Subject> subjects;
  final bool Function(String id) isPicked;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final subject in subjects)
          _SubjectPill(
            subject: subject,
            isPicked: isPicked(subject.id),
            onTap: () => onToggle(subject.id),
          ),
      ],
    );
  }
}

class _SubjectPill extends StatelessWidget {
  const _SubjectPill({
    required this.subject,
    required this.isPicked,
    required this.onTap,
  });

  final Subject subject;
  final bool isPicked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final locked = subject.isLocked;
    final ink = locked
        ? palette.textMuted
        : isPicked
        ? AppColors.keycapEdge
        : palette.text;
    return Semantics(
      button: !locked,
      selected: isPicked,
      label: locked ? '${subject.name}, always on' : null,
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: locked
                ? palette.surfaceRaised
                : isPicked
                ? AppColors.selected
                : palette.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: locked ? palette.border : palette.edge,
              width: AppKeycap.borderWidth,
            ),
            boxShadow: locked
                ? null
                : [BoxShadow(color: palette.edge, offset: const Offset(0, 2))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                locked ? Icons.lock_rounded : SubjectIcons.of(subject.id),
                size: 16,
                color: ink,
              ),
              const SizedBox(width: 4),
              Text(
                subject.name,
                style: AppTextStyles.labelStrong.copyWith(color: ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
