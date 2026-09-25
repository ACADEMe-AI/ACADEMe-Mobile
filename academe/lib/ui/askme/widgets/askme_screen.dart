import 'package:flutter/material.dart';

import '../../../domain/models/chat.dart';
import '../../../domain/models/pro.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/appear.dart';
import '../../core/ui/screen_scale.dart';
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
    required this.onMakeFlashcards,
  });

  final AskMeViewModel viewModel;
  final String name;
  final String? syllabus;
  final VoidCallback onBack;
  final VoidCallback onHistory;
  final VoidCallback onMakeFlashcards;

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
                      onMakeFlashcards: onMakeFlashcards,
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
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back',
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          color: context.palette.text,
        ),
        Text(
          'ASKMe',
          style: AppTextStyles.display.copyWith(
            fontSize: 24,
            color: context.palette.text,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onHistory,
          tooltip: 'History',
          icon: const Icon(Icons.history_rounded),
          color: context.palette.text,
        ),
        IconButton(
          onPressed: onNew,
          tooltip: 'New chat',
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
    required this.onMakeFlashcards,
  });

  final AskMeViewModel viewModel;
  final double padding;
  final VoidCallback onMakeFlashcards;

  List<FollowUp> _followUps() => switch (viewModel.mode) {
    ChatMode.solve => [
      FollowUp(
        label: 'Next step',
        isHighlighted: true,
        onTap: () => viewModel.send.execute('Next step, please.'),
      ),
      FollowUp(
        label: 'Full solution',
        onTap: () => viewModel.send.execute('Show me the full solution.'),
      ),
    ],
    ChatMode.quiz => [
      FollowUp(
        label: 'Next question',
        isHighlighted: true,
        onTap: () => viewModel.send.execute('Next question.'),
      ),
    ],
    ChatMode.explain => [
      FollowUp(label: 'Make flashcards', onTap: onMakeFlashcards),
      FollowUp(label: 'Quiz me', onTap: viewModel.quizMe),
      FollowUp(
        label: 'Go deeper',
        onTap: () => viewModel.send.execute('Go deeper.'),
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
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
                  followUps: i == lastIndex && isIdle ? _followUps() : const [],
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
        4 + MediaQuery.paddingOf(context).bottom,
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

  String get _message => switch (failure) {
    ChatFailure.unavailable =>
      'ASKMe isn’t ready yet. Pebby will be here soon.',
    ChatFailure.network => 'No connection. Check your internet and try again.',
    ChatFailure.signedOut => 'You’ve been logged out. Log in again.',
    ChatFailure.limitReached =>
      'That’s all your free questions for today. They come back at midnight.',
    ChatFailure.unknown => 'Something went wrong. Try again.',
  };

  @override
  Widget build(BuildContext context) {
    final isLimit = failure == ChatFailure.limitReached;
    final message = PebbyMessage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _message,
            style: AppTextStyles.label.copyWith(color: context.palette.text),
          ),
          if (isLimit)
            TextButton(
              onPressed: () => LimitSheet.show(context, ProFeature.askme),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
              child: const Text('Go Pro', style: AppTextStyles.labelStrong),
            )
          else if (failure != ChatFailure.unavailable)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
              child: const Text('Try again', style: AppTextStyles.labelStrong),
            ),
        ],
      ),
    );
    return isLimit
        ? OpensLimitSheet(feature: ProFeature.askme, child: message)
        : message;
  }
}
