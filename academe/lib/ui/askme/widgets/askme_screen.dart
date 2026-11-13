import 'package:flutter/material.dart';

import '../../../domain/models/chat.dart';
import '../../../domain/models/pro.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/appear.dart';
import '../../core/ui/screen_scale.dart';
import '../../core/ui/shell_edge.dart';
import '../../core/ui/tab_bar_layout.dart';
import '../../paywall/widgets/limit_sheet.dart';
import '../view_models/askme_view_model.dart';
import 'askme_empty_state.dart';
import 'chat_messages.dart';
import 'mode_bar.dart';

class AskMeScreen extends StatefulWidget {
  const AskMeScreen({
    super.key,
    required this.viewModel,
    required this.name,
    required this.syllabus,
    required this.onBack,
    required this.onHistory,
    this.onShellStep,
  });

  final AskMeViewModel viewModel;
  final String name;
  final String? syllabus;
  final VoidCallback onBack;
  final VoidCallback onHistory;
  final ValueChanged<int>? onShellStep;

  @override
  State<AskMeScreen> createState() => _AskMeScreenState();
}

class _AskMeScreenState extends State<AskMeScreen> {
  static const _axisSlop = 12.0;

  int _modeDir = 1;
  bool _ignoreModeDrag = false;
  bool? _modeHorizontal;
  double _modeDx = 0;
  double _modeDy = 0;

  AskMeViewModel get _viewModel => widget.viewModel;

  void _setMode(ChatMode mode) {
    final from = _viewModel.mode;
    if (from == mode) return;
    setState(() => _modeDir = mode.index >= from.index ? 1 : -1);
    _viewModel.setMode(mode);
  }

  void _onModeStep(int delta) {
    final i = _viewModel.mode.index + delta;
    if (i < 0 || i >= ChatMode.values.length) {
      widget.onShellStep?.call(delta);
      return;
    }
    _setMode(ChatMode.values[i]);
  }

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding - 8, 4, padding - 8, 0),
            child: _Header(
              onBack: widget.onBack,
              onHistory: widget.onHistory,
              onNew: _viewModel.isEmpty ? null : _viewModel.newChat,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ModeBar(mode: _viewModel.mode, onSelect: _setMode),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Builder(
              builder: (swipeContext) => Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (e) {
                  final box = swipeContext.findRenderObject() as RenderBox?;
                  final width = box?.size.width ?? 0;
                  _ignoreModeDrag =
                      width <= 0 ||
                      ShellEdge.contains(e.localPosition.dx, width);
                  _modeHorizontal = null;
                  _modeDx = 0;
                  _modeDy = 0;
                },
                onPointerMove: (e) {
                  if (_ignoreModeDrag) return;
                  _modeDx += e.delta.dx;
                  _modeDy += e.delta.dy;
                  if (_modeHorizontal == null) {
                    if (_modeDx.abs() < _axisSlop &&
                        _modeDy.abs() < _axisSlop) {
                      return;
                    }
                    _modeHorizontal = _modeDx.abs() > _modeDy.abs();
                  }
                },
                onPointerUp: (_) {
                  if (_ignoreModeDrag || _modeHorizontal != true) return;
                  if (_modeDx.abs() < 40) return;
                  _onModeStep(_modeDx < 0 ? 1 : -1);
                },
                onPointerCancel: (_) {
                  _ignoreModeDrag = true;
                  _modeHorizontal = null;
                  _modeDx = 0;
                  _modeDy = 0;
                },
                child: AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : ModeBar.slide,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (current, previous) => Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.topCenter,
                    children: [...previous, ?current],
                  ),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: animation.drive(
                        Tween(
                          begin: Offset(_modeDir.toDouble(), 0),
                          end: Offset.zero,
                        ),
                      ),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(_viewModel.mode),
                    child: _viewModel.isEmpty
                        ? AskMeEmptyState(
                            name: widget.name,
                            syllabus: widget.syllabus,
                            mode: _viewModel.mode,
                            onAsk: _viewModel.send.execute,
                          )
                        : _Conversation(
                            viewModel: _viewModel,
                            padding: padding,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onBack,
    required this.onHistory,
    required this.onNew,
  });

  final VoidCallback onBack;
  final VoidCallback onHistory;
  final VoidCallback? onNew;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: l10n.actionBack,
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          color: context.palette.text,
        ),
        Text(
          l10n.navAskMe,
          style: AppTextStyles.display.copyWith(
            fontSize: 24,
            color: context.palette.text,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onHistory,
          tooltip: l10n.historyTitle,
          icon: const Icon(Icons.history_rounded),
          color: context.palette.text,
        ),
        IconButton(
          onPressed: onNew,
          tooltip: l10n.askmeNewChat,
          icon: const Icon(Icons.add_rounded, size: 28),
          color: context.palette.text,
          disabledColor: context.palette.border,
        ),
      ],
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation({
    required this.viewModel,
    required this.padding,
  });

  final AskMeViewModel viewModel;
  final double padding;

  List<FollowUp> _followUps(AppLocalizations l10n) => switch (viewModel.mode) {
    ChatMode.solve => [
      FollowUp(
        label: l10n.askmeFollowNextStep,
        isHighlighted: true,
        onTap: () => viewModel.send.execute(l10n.askmeSendNextStep),
      ),
      FollowUp(
        label: l10n.askmeFollowFullSolution,
        onTap: () => viewModel.send.execute(l10n.askmeSendFullSolution),
      ),
    ],
    ChatMode.quiz => [
      FollowUp(
        label: l10n.askmeFollowNextQuestion,
        isHighlighted: true,
        onTap: () => viewModel.send.execute(l10n.askmeSendNextQuestion),
      ),
    ],
    ChatMode.explain => [
      FollowUp(
        label: l10n.askmeFollowQuizMe,
        onTap: () {
          viewModel.setMode(ChatMode.quiz);
          viewModel.send.execute(l10n.askmeSendQuizMe);
        },
      ),
      FollowUp(
        label: l10n.askmeFollowGoDeeper,
        onTap: () => viewModel.send.execute(l10n.askmeSendGoDeeper),
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final messages = viewModel.messages;
    final lastIndex = messages.length - 1;
    final isIdle = !viewModel.isThinking;
    final items = <(Key, Widget)>[
      for (var i = 0; i < messages.length; i++)
        (
          ValueKey('m${messages[i].id}'),
          messages[i].isPebby
              ? PebbyReply(
                  message: messages[i],
                  onRate: (rating) => viewModel.rate(messages[i], rating),
                  onReport: (reason) => viewModel.report(messages[i], reason),
                  onRetry: i == lastIndex && isIdle
                      ? viewModel.regenerate.execute
                      : null,
                  followUps: i == lastIndex && isIdle
                      ? _followUps(l10n)
                      : const [],
                )
              : StudentBubble(text: messages[i].body),
        ),
      if (viewModel.isThinking)
        (const ValueKey('thinking'), const ThinkingBubble()),
      if (viewModel.unsent case final text?) ...[
        (const ValueKey('unsent'), StudentBubble(text: text)),
        (
          const ValueKey('failed'),
          _SendFailed(
            failure: viewModel.failure ?? ChatFailure.unknown,
            onRetry: viewModel.resend,
          ),
        ),
      ] else if (viewModel.failure case final failure?)
        (
          const ValueKey('failed'),
          _SendFailed(failure: failure, onRetry: viewModel.regenerate.execute),
        ),
    ];
    final count = items.length;
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.fromLTRB(
        padding,
        16,
        padding,
        4 + TabBarLayout.scrollBottomPadding(context),
      ),
      itemCount: count,
      findChildIndexCallback: (key) {
        final index = items.indexWhere((item) => item.$1 == key);
        return index < 0 ? null : count - 1 - index;
      },
      itemBuilder: (context, index) {
        final (key, child) = items[count - 1 - index];
        return Padding(
          key: key,
          padding: const EdgeInsets.only(bottom: 12),
          child: Appear(child: child),
        );
      },
    );
  }
}

class _SendFailed extends StatelessWidget {
  const _SendFailed({required this.failure, required this.onRetry});

  final ChatFailure failure;
  final VoidCallback onRetry;

  String _message(AppLocalizations l10n) => switch (failure) {
    ChatFailure.unavailable => l10n.askmeFailureUnavailable,
    ChatFailure.network => l10n.failureNetwork,
    ChatFailure.signedOut => l10n.askmeFailureSignedOut,
    ChatFailure.limitReached => l10n.askmeFailureLimitReached,
    ChatFailure.unknown => l10n.failureUnknown,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLimit = failure == ChatFailure.limitReached;
    final message = PebbyMessage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _message(l10n),
            style: AppTextStyles.label.copyWith(color: context.palette.text),
          ),
          if (isLimit)
            TextButton(
              onPressed: () => LimitSheet.show(context, ProFeature.askme),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
              child: Text(l10n.actionGoPro, style: AppTextStyles.labelStrong),
            )
          else if (failure != ChatFailure.unavailable)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
              child: Text(l10n.actionTryAgain, style: AppTextStyles.labelStrong),
            ),
        ],
      ),
    );
    return isLimit
        ? OpensLimitSheet(feature: ProFeature.askme, child: message)
        : message;
  }
}
