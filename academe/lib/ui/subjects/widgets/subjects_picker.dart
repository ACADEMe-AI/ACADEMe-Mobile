import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../view_models/subjects_view_model.dart';
import 'stream_cards.dart';
import 'subject_pills.dart';

class SubjectsPicker extends StatelessWidget {
  const SubjectsPicker({super.key, required this.viewModel, this.footnote});

  final SubjectsViewModel viewModel;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (!viewModel.isReady) {
      return SizedBox(
        height: 120,
        child: Center(
          child: viewModel.load.hasError
              ? TextButton(
                  onPressed: viewModel.load.execute,
                  child: const Text('Couldn’t load your subjects. Retry'),
                )
              : const CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (viewModel.stage == SubjectsStage.stream) {
      return StreamCards(
        streams: viewModel.streams,
        index: viewModel.streamIndex,
        onChanged: viewModel.focusStream,
      );
    }
    final pills = viewModel.isSenior
        ? [
            const _Label('Main'),
            _Pills(viewModel: viewModel, isMain: true),
            const SizedBox(height: 12),
            const _Label('Optional'),
            _Pills(viewModel: viewModel, isMain: false),
          ]
        : [_Pills(viewModel: viewModel, isMain: true)];
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...pills,
          if (footnote case final text?) ...[
            const SizedBox(height: 12),
            Text(
              text,
              style: AppTextStyles.caption.copyWith(color: palette.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pills extends StatelessWidget {
  const _Pills({required this.viewModel, required this.isMain});

  final SubjectsViewModel viewModel;
  final bool isMain;

  @override
  Widget build(BuildContext context) {
    return SubjectPills(
      subjects: isMain ? viewModel.main : viewModel.optional,
      isPicked: viewModel.isPicked,
      onToggle: viewModel.toggle,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: context.palette.textMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: .6,
        ),
      ),
    );
  }
}
