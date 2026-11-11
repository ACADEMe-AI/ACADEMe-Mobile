import 'package:flutter/material.dart';

import '../../../data/repositories/feedback_repository.dart';
import '../../../domain/models/feedback.dart';
import '../../../utils/result.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../view_models/help_view_model.dart';
import 'settings_page.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({
    super.key,
    required this.category,
    required this.viewModel,
  });

  final FeedbackCategory category;
  final HelpViewModel viewModel;

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _message = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.viewModel.submit.addListener(_onSubmit);
  }

  @override
  void dispose() {
    widget.viewModel.submit.removeListener(_onSubmit);
    _message.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!mounted) return;
    switch (widget.viewModel.submit.result) {
      case Ok():
        Navigator.of(context).pop(true);
      case Error(:final error):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(feedbackFailureMessage(error, context.l10n)),
            ),
          );
      case null:
        break;
    }
  }

  Future<void> _send() async {
    await widget.viewModel.submit.execute((
      category: widget.category,
      message: _message.text,
    ));
  }

  String get _title {
    final l10n = context.l10n;
    return switch (widget.category) {
      FeedbackCategory.wrongAnswer => l10n.feedbackWrongAnswer,
      FeedbackCategory.bug => l10n.feedbackBug,
      FeedbackCategory.feature => l10n.feedbackFeature,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsPage(
      title: _title,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _message,
            focusNode: _focus,
            autofocus: true,
            minLines: 4,
            maxLines: 8,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: l10n.feedbackHint,
              counterText: '',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ListenableBuilder(
            listenable: widget.viewModel.submit,
            builder: (context, _) {
              final sending = widget.viewModel.submit.isRunning;
              return AppButton(
                label: sending ? l10n.authSending : l10n.feedbackSend,
                onTap: sending ? null : _send,
                isPrimary: true,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.feedbackLimitNote,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
