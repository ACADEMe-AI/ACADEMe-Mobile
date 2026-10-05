import 'package:flutter/material.dart';

import '../../../utils/result.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../view_models/subjects_view_model.dart';
import 'subjects_picker.dart';

class SubjectsSheet extends StatefulWidget {
  const SubjectsSheet({
    super.key,
    required this.viewModel,
    this.onlyStream = false,
  });

  final SubjectsViewModel viewModel;
  final bool onlyStream;

  static Future<bool> show(
    BuildContext context, {
    required SubjectsViewModel viewModel,
    bool onlyStream = false,
  }) async {
    if (viewModel.isReady) {
      viewModel.reset(start: onlyStream ? SubjectsStage.stream : null);
    }
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.palette.surface,
      barrierColor: AppColors.keycapEdge.withValues(alpha: .35),
      showDragHandle: true,
      builder: (_) =>
          SubjectsSheet(viewModel: viewModel, onlyStream: onlyStream),
    );
    return saved ?? false;
  }

  @override
  State<SubjectsSheet> createState() => _SubjectsSheetState();
}

class _SubjectsSheetState extends State<SubjectsSheet> {
  SubjectsViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    if (!_viewModel.isReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  Future<void> _load() async {
    await _viewModel.load.execute();
    if (!mounted) return;
    _viewModel.reset(start: widget.onlyStream ? SubjectsStage.stream : null);
  }

  Future<void> _save() async {
    await _viewModel.save.execute();
    if (mounted && _viewModel.save.result is Ok) {
      Navigator.of(context).pop(true);
    }
  }

  void _choose() {
    final focused = _viewModel.focusedStream;
    if (focused == null) return;
    _viewModel.chooseStream(focused);
    if (widget.onlyStream) _save();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final picksStream =
            _viewModel.isReady && _viewModel.stage == SubjectsStage.stream;
        final saving = _viewModel.save.isRunning;
        final stream = _viewModel.stream;
        final caption = _viewModel.isSenior && stream != null && !picksStream
            ? '${_viewModel.syllabusLabel} · ${stream.name}'
            : _viewModel.syllabusLabel;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  picksStream ? 'Your stream' : 'Your subjects',
                  style: AppTextStyles.display.copyWith(
                    fontSize: 24,
                    color: palette.text,
                  ),
                ),
                Text(
                  caption,
                  style: AppTextStyles.label.copyWith(color: palette.textMuted),
                ),
                const SizedBox(height: 16),
                SubjectsPicker(viewModel: _viewModel),
                if (_viewModel.save.result case Error(:final error))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      failureMessage(error),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                AppButton(
                  label: saving
                      ? 'Saving…'
                      : picksStream
                      ? 'Choose ${_viewModel.focusedStream?.name ?? ''}'
                      : 'Save',
                  isPrimary: true,
                  isEnabled: _viewModel.isReady && !saving,
                  onTap: picksStream ? _choose : _save,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
