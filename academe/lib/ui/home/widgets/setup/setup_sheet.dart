import 'package:flutter/material.dart';

import '../../../../domain/models/profile.dart';
import '../../../../utils/result.dart';
import '../../../auth/widgets/auth_failure_text.dart';
import '../../../core/themes/app_theme.dart';
import '../../view_models/home_view_model.dart';
import 'age_step.dart';
import 'board_step.dart';
import 'class_step.dart';
import 'language_step.dart';
import 'setup_reward_pill.dart';

class SetupSheet extends StatefulWidget {
  const SetupSheet({super.key, required this.viewModel, required this.start});

  final HomeViewModel viewModel;
  final SetupTask start;

  static Future<void> show(
    BuildContext context, {
    required HomeViewModel viewModel,
    required SetupTask start,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.palette.surface,
      barrierColor: AppColors.keycapEdge.withValues(alpha: .45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => SetupSheet(viewModel: viewModel, start: start),
    );
  }

  @override
  State<SetupSheet> createState() => _SetupSheetState();
}

class _SetupSheetState extends State<SetupSheet> {
  late SetupTask _task = widget.start;

  HomeViewModel get _viewModel => widget.viewModel;

  Future<void> _submit(ProfileUpdate update) async {
    await _viewModel.save.execute(update);
    if (!mounted || _viewModel.save.result is! Ok) return;
    final next = _viewModel.nextTask(after: _task);
    if (next == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _task = next);
    }
  }

  void _back() {
    if (_task.index > 0) {
      setState(() => _task = SetupTask.values[_task.index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: _Handle()),
              const SizedBox(height: 8),
              _SheetHeader(
                task: _task,
                onBack: _task.index > 0 ? _back : null,
                onLater: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
              AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(.06, 0), end: Offset.zero),
                      ),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_task),
                    child: _step(_task),
                  ),
                ),
              ),
              if (_viewModel.save.result case Error(:final error))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    failureMessage(error),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(color: AppColors.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(SetupTask task) {
    final profile = _viewModel.profile;
    final isSaving = _viewModel.save.isRunning;
    return switch (task) {
      SetupTask.language => LanguageStep(
        initial: profile.language,
        isSaving: isSaving,
        onSubmit: (language) => _submit(ProfileUpdate(language: language)),
      ),
      SetupTask.age => AgeStep(
        initial: profile.birthYear,
        isSaving: isSaving,
        onSubmit: (year) => _submit(ProfileUpdate(birthYear: year)),
      ),
      SetupTask.classLevel => ClassStep(
        initial: profile.classLevel,
        isSaving: isSaving,
        onSubmit: (value) => _submit(ProfileUpdate(classLevel: value)),
      ),
      SetupTask.board => BoardStep(
        initial: profile.board,
        isLast: _viewModel.nextTask(after: task) == null,
        isSaving: isSaving,
        onSubmit: (board) => _submit(ProfileUpdate(board: board)),
      ),
    };
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.task,
    required this.onBack,
    required this.onLater,
  });

  final SetupTask task;
  final VoidCallback? onBack;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            tooltip: 'Back',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            icon: const Icon(Icons.chevron_left_rounded),
            color: context.palette.text,
          ),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'SET UP · ${task.index + 1}/${SetupTask.values.length}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: context.palette.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const SetupRewardPill(label: '+${HomeViewModel.xpPerTask} XP'),
            ],
          ),
        ),
        TextButton(
          onPressed: onLater,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.only(left: 12),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            alignment: Alignment.centerRight,
          ),
          child: const Text('Later', style: AppTextStyles.labelStrong),
        ),
      ],
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.palette.border,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.full)),
        ),
      ),
    );
  }
}
