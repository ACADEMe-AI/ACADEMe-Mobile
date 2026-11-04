import 'package:flutter/material.dart';

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
        final picker = SubjectsPicker(
          viewModel: viewModel,
          footnote: viewModel.isSenior
              ? null
              : 'You can change this any time in Me.',
        );
        final focused = viewModel.focusedStream;
        if (viewModel.isReady &&
            viewModel.stage == SubjectsStage.stream &&
            focused != null) {
          return SetupStepFrame(
            title:
                'What do you study in Class ${viewModel.profile.classLevel}?',
            buttonLabel: 'Choose ${focused.name}',
            isSaving: false,
            onSubmit: () => viewModel.chooseStream(focused),
            body: picker,
          );
        }
        final stream = viewModel.stream;
        return SetupStepFrame(
          title: viewModel.isSenior
              ? 'Anything else?'
              : 'Which subjects do you study?',
          subtitle: viewModel.isSenior
              ? '${stream?.name ?? viewModel.syllabusLabel}. '
                    'Your main subjects are in.'
              : '${viewModel.syllabusLabel}. '
                    'Tap to remove any you don’t take.',
          buttonLabel: isLast ? 'Finish setup' : 'Continue',
          isSaving: isSaving,
          isEnabled: viewModel.isReady,
          onSubmit: () => onSubmit(viewModel.picks),
          body: picker,
        );
      },
    );
  }
}
