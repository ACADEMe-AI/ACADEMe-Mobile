import 'package:flutter/material.dart';

import '../../../config/links.dart';
import '../../../domain/models/feedback.dart';
import '../../core/l10n/app_l10n.dart';
import '../view_models/help_view_model.dart';
import 'feedback_form_screen.dart';
import 'settings_list.dart';
import 'settings_page.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key, required this.viewModel});

  final HelpViewModel viewModel;

  static const email = Links.supportEmail;

  Future<void> _openCategory(
    BuildContext context,
    FeedbackCategory category,
  ) async {
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            FeedbackFormScreen(category: category, viewModel: viewModel),
      ),
    );
    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.helpThanks)));
      viewModel.submit.clearResult();
    }
  }

  String _categoryLabel(BuildContext context, FeedbackCategory category) {
    final l10n = context.l10n;
    return switch (category) {
      FeedbackCategory.wrongAnswer => l10n.feedbackWrongAnswer,
      FeedbackCategory.bug => l10n.feedbackBug,
      FeedbackCategory.feature => l10n.feedbackFeature,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsPage(
      title: l10n.meHelpAndFeedback,
      children: [
        SettingsGroup(
          title: l10n.helpTellUs,
          children: [
            SettingsRow(
              label: _categoryLabel(context, FeedbackCategory.wrongAnswer),
              onTap: () => _openCategory(context, FeedbackCategory.wrongAnswer),
            ),
            SettingsRow(
              label: _categoryLabel(context, FeedbackCategory.bug),
              onTap: () => _openCategory(context, FeedbackCategory.bug),
            ),
            SettingsRow(
              label: _categoryLabel(context, FeedbackCategory.feature),
              onTap: () => _openCategory(context, FeedbackCategory.feature),
            ),
            SettingsRow(label: l10n.helpEmailUs, value: email),
          ],
        ),
      ],
    );
  }
}
