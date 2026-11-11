import 'package:flutter/material.dart';

import '../../../domain/models/chat.dart';
import '../../../domain/models/pro.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/appear.dart';
import '../../core/ui/screen_scale.dart';
import '../../core/ui/tab_bar_layout.dart';
import '../../paywall/widgets/limit_sheet.dart';
import '../view_models/askme_view_model.dart';
import 'askme_empty_state.dart';
import 'chat_messages.dart';
import 'mode_bar.dart';

class AskMeScreen extends StatelessWidget {
  const AskMeScreen({
    super.key,
    required this.viewModel,
    required this.name,
    required this.syllabus,
    required this.onBack,
    required this.onHistory,
  });

  final AskMeViewModel viewModel;
  final String name;
  final String? syllabus;
  final VoidCallback onBack;
  final VoidCallback onHistory;

  static const _emptyKey = ValueKey('empty');
  static const _chatKey = ValueKey('chat');

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding - 8, 4, padding - 8, 0),
            child: _Header(
              onBack: onBack,
              onHistory: onHistory,
              onNew: viewModel.isEmpty ? null : viewModel.newChat,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ModeBar(mode: viewModel.mode, onSelect: viewModel.setMode),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(
                    Tween(
                      begin: Offset(0, child.key == _emptyKey ? -.06 : .04),
                      end: Offset.zero,
                    ),
                  ),
                  child: child,
                ),
              ),
              child: viewModel.isEmpty
                  ? AskMeEmptyState(
                      key: _emptyKey,
                      name: name,
                      syllabus: syllabus,
                      mode: viewModel.mode,
                      onAsk: viewModel.send.execute,
                    )
                  : _Conversation(
                      key: _chatKey,
                      viewModel: viewModel,
                      padding: padding,
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
    super.key,
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
