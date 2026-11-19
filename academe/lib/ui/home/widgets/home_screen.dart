import 'package:flutter/material.dart';

import '../../../domain/models/app_language.dart';
import '../../../domain/models/auth_failure.dart';
import '../../../domain/models/folder.dart';
import '../../../utils/result.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/syllabus_label.dart';
import '../../core/ui/screen_scale.dart';
import '../../core/ui/tab_bar_layout.dart';
import '../../core/ui/top_notice.dart';
import '../../study/view_models/study_view_model.dart';
import '../../subjects/widgets/subjects_sheet.dart';
import '../view_models/home_view_model.dart';
import '../view_models/today_view_model.dart';
import 'ask_bar.dart';
import 'ask_hint.dart';
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
  bool _didShowLoadNotice = false;

  HomeViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _flight = AnimationController(
      vsync: this,
      duration: SetupRewardFlight.duration,
    );
    _viewModel.load.addListener(_onLoadChanged);
    _onLoadChanged();
  }

  @override
  void dispose() {
    _viewModel.load.removeListener(_onLoadChanged);
    _flight.dispose();
    super.dispose();
  }

  void _onLoadChanged() {
    _maybeOpenSetup();
    _maybeShowLoadNotice();
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

  void _maybeShowLoadNotice() {
    if (!_viewModel.load.hasError) {
      _didShowLoadNotice = false;
      return;
    }
    if (_didShowLoadNotice || !mounted) return;
    _didShowLoadNotice = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_viewModel.load.hasError) return;
      final error = switch (_viewModel.load.result) {
        Error(:final error) => error,
        _ => null,
      };
      final offline =
          error is AuthException && error.failure == AuthFailure.network;
      context.showTopNotice(
        offline
            ? context.l10n.homeDashboardLoadError
            : failureMessage(error ?? Exception(), context.l10n),
        kind: offline ? TopNoticeKind.offline : TopNoticeKind.error,
      );
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
        final syllabusLabel = syllabusLabelForProfile(
          context.l10n,
          _viewModel.profile,
        );
        final flightPath = _flightPath;
        return Stack(
          key: _stackKey,
          children: [
            RefreshIndicator(
              onRefresh: _viewModel.load.execute,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  scale.pagePadding,
                  8,
                  scale.pagePadding,
                  24 + TabBarLayout.scrollBottomPadding(context),
                ),
                children: [
                  HomeGreeting(
                    hello: (_viewModel.profile.language ?? AppLanguage.english)
                        .hello(
                          _viewModel.account?.firstName ??
                              context.l10n.helloFallbackName,
                        ),
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
                        label: context.l10n.homeSolveHomework,
                        onTap: widget.onSolve,
                      ),
                      QuickAction(
                        icon: Icons.fact_check_rounded,
                        label: context.l10n.homeCheckAnswer,
                        onTap: widget.onCheck,
                      ),
                      QuickAction(
                        icon: Icons.style_rounded,
                        label: context.l10n.homeFlashcards,
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
