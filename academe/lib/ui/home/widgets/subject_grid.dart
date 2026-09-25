import 'package:flutter/material.dart';

import '../../../domain/models/subject.dart';
import '../../core/themes/app_theme.dart';

class SubjectGrid extends StatelessWidget {
  const SubjectGrid({
    super.key,
    required this.subjects,
    required this.syllabus,
  });

  final List<Subject> subjects;
  final String? syllabus;

  @override
  Widget build(BuildContext context) {
    if (syllabus == null || subjects.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.palette.border, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Text(
            'Set your class and board to see your subjects',
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(
              color: context.palette.textMuted,
            ),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.4,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.palette.tints[index % 5],
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subjects[index].name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelStrong.copyWith(
                color: context.palette.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
