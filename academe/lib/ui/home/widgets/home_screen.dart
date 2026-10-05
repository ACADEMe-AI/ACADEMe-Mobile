import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
import '../../core/ui/screen_scale.dart';
import '../../study/view_models/study_view_model.dart';
import '../../subjects/widgets/subjects_sheet.dart';
import '../view_models/home_view_model.dart';
import '../view_models/today_view_model.dart';
import 'ask_bar.dart';
import 'ask_hint.dart';
import 'dashboard_load_error.dart';
import 'home_greeting.dart';
import 'pick_subjects_card.dart';
import 'quick_actions.dart';
import 'setup/setup_checklist.dart';
import 'setup/setup_reward_flight.dart';
import 'setup/setup_sheet.dart';
import 'subject_rows.dart';
import 'today_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
    this.opensSetup = false,
    required this.onAsk,
    this.today,
    this.onOpenTask,
    required this.onFlashcards,
    required this.onSolve,
    required this.onCheck,
    required this.study,
    this.onOpenSubject,
  });

  final HomeViewModel viewModel;
  final bool opensSetup;
  final VoidCallback onAsk;
  final TodayViewModel? today;
  final ValueChanged<StudyTask>? onOpenTask;
  final VoidCallback onFlashcards;
  final VoidCallback onSolve;
  final VoidCallback onCheck;
  final StudyViewModel study;
  final ValueChanged<String>? onOpenSubject;

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
    await SetupSheet.show(
      context,
      viewModel: _viewModel,
      start: _viewModel.startAt(start),
    );
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

  Future<void> _openSubjects() async {
    final picker = _viewModel.subjectsPicker();
    await SubjectsSheet.show(context, viewModel: picker);
    picker.dispose();
  }

  void _pickFromCard() {
    _viewModel.dismissPickSubjects();
    _openSubjects();
  }

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null || !box.attached) return null;
    return box.localToGlobal(Offset.zero, ancestor: stack) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final scale = ScreenScale.of(context);
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
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
                HomeGreeting(
                  name: _viewModel.account?.firstName ?? 'there',
                  syllabus: syllabusLabel,
                  xpKey: _xpKey,
                  xp: _viewModel.displayedXp,
                  streak: _viewModel.profile.streak,
                ),
                const SizedBox(height: 16),
                AskBar(onTap: widget.onAsk),
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
                      onTap: widget.onSolve,
                    ),
                    QuickAction(
                      icon: Icons.fact_check_rounded,
                      label: 'Check my answer',
                      onTap: widget.onCheck,
                    ),
                    QuickAction(
                      icon: Icons.style_rounded,
                      label: 'Flashcards',
                      onTap: widget.onFlashcards,
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
                  DashboardLoadError(onRetry: _viewModel.load.execute),
                ],
                if (_viewModel.showsPickSubjects) ...[
                  const SizedBox(height: 16),
                  PickSubjectsCard(
                    onPick: _pickFromCard,
                    onDismiss: _viewModel.dismissPickSubjects,
                  ),
                ],
                const SizedBox(height: 24),
                SubjectRows(
                  study: widget.study,
                  hasSyllabus: _viewModel.profile.hasSyllabus,
                  onEdit: _openSubjects,
                  onOpen: widget.onOpenSubject ?? (_) {},
                ),
              ],
            ),
            if (flightPath case (final from, final to))
              SetupRewardFlight(
                progress: _flight,
                from: from,
                to: to,
                amount: _viewModel.pendingXp,
              ),
          ],
        );
      },
    );
  }
}
