import 'package:flutter/material.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../../subjects/view_models/subjects_view_model.dart';
import '../../../subjects/widgets/subjects_picker.dart';
import 'setup_step_frame.dart';

class SubjectsStep extends StatelessWidget {
  const SubjectsStep({
    super.key,
    required this.viewModel,
    required this.isLast,
    required this.isSaving,
    required this.onSubmit,
  });

  final SubjectsViewModel viewModel;
  final bool isLast;
  final bool isSaving;
  final ValueChanged<List<String>> onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final l10n = context.l10n;
        final picker = SubjectsPicker(
          viewModel: viewModel,
          footnote: viewModel.isSenior
              ? null
              : l10n.setupChangeInMe,
        );
        final focused = viewModel.focusedStream;
        if (viewModel.isReady &&
            viewModel.stage == SubjectsStage.stream &&
            focused != null) {
          return SetupStepFrame(
            title: l10n.setupStreamTitle(viewModel.profile.classLevel!),
            buttonLabel: l10n.setupChooseLanguage(focused.name),
            isSaving: false,
            onSubmit: () => viewModel.chooseStream(focused),
            body: picker,
          );
        }
        final stream = viewModel.stream;
        final syllabus = viewModel.isSenior
            ? (stream?.name ?? viewModel.syllabusLabel)
            : viewModel.syllabusLabel;
        return SetupStepFrame(
          title: viewModel.isSenior
              ? l10n.setupAnythingElse
              : l10n.setupWhichSubjects,
          subtitle: viewModel.isSenior
              ? l10n.setupMainSubjectsIn(syllabus)
              : l10n.setupTapToRemove(syllabus),
          buttonLabel: isLast ? l10n.setupFinish : l10n.authContinue,
          isSaving: isSaving,
          isEnabled: viewModel.isReady,
          onSubmit: () => onSubmit(viewModel.picks),
          body: picker,
        );
      },
    );
  }
}
