import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/screen_scale.dart';
import '../view_models/home_view_model.dart';
import '../view_models/today_view_model.dart';
import 'ask_bar.dart';
import 'ask_hint.dart';
import 'quick_actions.dart';
import 'setup/setup_checklist.dart';
import 'setup/setup_reward_flight.dart';
import 'setup/setup_sheet.dart';
import 'subject_grid.dart';
import 'today_card.dart';
import 'xp_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
    this.opensSetup = false,
    this.onAsk,
    this.today,
    this.onOpenTask,
    this.onFlashcards,
    this.onSolve,
    this.onCheck,
  });

  final HomeViewModel viewModel;
  final bool opensSetup;
  final VoidCallback? onAsk;
  final TodayViewModel? today;
  final ValueChanged<StudyTask>? onOpenTask;
  final VoidCallback? onFlashcards;
  final VoidCallback? onSolve;
  final VoidCallback? onCheck;

  static const setupDelay = Duration(milliseconds: 400);
  static const rewardDelay = Duration(milliseconds: 350);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _stackKey = GlobalKey();
  final _cardKey = GlobalKey();
  final _xpKey = GlobalKey();
  late final AnimationController _flight;

  (Rect, Rect)? _flightPath;
  bool _hasOpenedSetup = false;

  HomeViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _flight = AnimationController(
      vsync: this,
      duration: SetupRewardFlight.duration,
    );
    _viewModel.load.addListener(_maybeOpenSetup);
    _maybeOpenSetup();
  }

  @override
  void dispose() {
    _viewModel.load.removeListener(_maybeOpenSetup);
    _flight.dispose();
    super.dispose();
  }

  void _maybeOpenSetup() {
    if (!widget.opensSetup || _hasOpenedSetup) return;
    if (_viewModel.load.isRunning || !_viewModel.load.isCompleted) return;
    if (_viewModel.profile.setupDone) return;
    _hasOpenedSetup = true;
    Future.delayed(HomeScreen.setupDelay, () {
      if (mounted) _openSetup(_viewModel.nextTask() ?? SetupTask.language);
    });
  }

  Future<void> _openSetup(SetupTask start) async {
    await SetupSheet.show(context, viewModel: _viewModel, start: start);
    if (mounted && _viewModel.isRewardPending) await _playReward();
  }

  Future<void> _playReward() async {
    await Future<void>.delayed(HomeScreen.rewardDelay);
    final from = _rectOf(_cardKey);
    final to = _rectOf(_xpKey);
    if (!mounted) return;
    if (from == null || to == null) {
      _viewModel.rewardLanded();
      return;
    }
    setState(() => _flightPath = (from, to));
    await _flight.forward(from: 0);
    if (!mounted) return;
    _viewModel.rewardLanded();
    setState(() => _flightPath = null);
  }

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null || !box.attached) return null;
    return box.localToGlobal(Offset.zero, ancestor: stack) & box.size;
  }

  void _comingSoon(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scale = ScreenScale.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final profile = _viewModel.profile;
        final syllabus = profile.hasSyllabus
            ? 'Class ${profile.classLevel} · ${profile.board!.code}'
            : null;
        final syllabusLabel = _viewModel.syllabusLabel;
        final flightPath = _flightPath;
        return Stack(
          key: _stackKey,
          children: [
            ListView(
              padding: EdgeInsets.fromLTRB(
                scale.pagePadding,
                8,
                scale.pagePadding,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                _Greeting(
                  name: _viewModel.account?.firstName ?? 'there',
                  syllabus: syllabusLabel,
                  xpKey: _xpKey,
                  xp: _viewModel.displayedXp,
                ),
                const SizedBox(height: 16),
                AskBar(
                  onTap:
                      widget.onAsk ??
                      () => _comingSoon('ASKMe is coming soon.'),
                ),
                if (_viewModel.showsAskHint) ...[
                  const SizedBox(height: 4),
                  AskHint(onDismiss: _viewModel.dismissAskHint),
                ],
                const SizedBox(height: 12),
                QuickActions(
                  actions: [
                    QuickAction(
                      icon: Icons.photo_camera_rounded,
                      label: 'Solve homework',
                      onTap:
                          widget.onSolve ??
                          () => _comingSoon('Homework help is coming soon.'),
                    ),
                    QuickAction(
                      icon: Icons.fact_check_rounded,
                      label: 'Check my answer',
                      onTap:
                          widget.onCheck ??
                          () => _comingSoon('Answer checking is coming soon.'),
                    ),
                    QuickAction(
                      icon: Icons.style_rounded,
                      label: 'Flashcards',
                      onTap:
                          widget.onFlashcards ??
                          () => _comingSoon('Flashcards are coming soon.'),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _viewModel.showsChecklist
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Visibility(
                            visible: flightPath == null,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: SetupChecklist(
                              key: _cardKey,
                              viewModel: _viewModel,
                              onOpen: _openSetup,
                            ),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                if (widget.today case final today?)
                  TodayCard(
                    viewModel: today,
                    onOpen: widget.onOpenTask ?? (_) {},
                  ),
                if (_viewModel.load.hasError &&
                    !_viewModel.profile.setupDone) ...[
                  const SizedBox(height: 12),
                  _LoadError(onRetry: _viewModel.load.execute),
                ],
                const SizedBox(height: 24),
                Text(
                  'Your subjects',
                  style: AppTextStyles.subhead.copyWith(
                    fontSize: 16,
                    color: context.palette.text,
                  ),
                ),
                const SizedBox(height: 8),
                SubjectGrid(subjects: _viewModel.subjects, syllabus: syllabus),
              ],
            ),
            if (flightPath case (final from, final to))
              SetupRewardFlight(progress: _flight, from: from, to: to),
          ],
        );
      },
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({
    required this.name,
    required this.syllabus,
    required this.xpKey,
    required this.xp,
  });

  final String name;
  final String? syllabus;
  final GlobalKey xpKey;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $name!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.display.copyWith(
                  fontSize: 28,
                  color: context.palette.text,
                ),
              ),
              if (syllabus case final label?)
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.palette.textMuted,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.local_fire_department_rounded,
          size: 20,
          color: context.palette.border,
        ),
        Text(
          '0',
          style: AppTextStyles.labelStrong.copyWith(
            color: context.palette.textMuted,
          ),
        ),
        const SizedBox(width: 12),
        XpChip(key: xpKey, xp: xp),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Couldn’t load your dashboard.',
            style: AppTextStyles.label.copyWith(color: AppColors.error),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: const Text('Retry', style: AppTextStyles.labelStrong),
        ),
      ],
    );
  }
}
