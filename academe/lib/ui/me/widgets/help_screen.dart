import 'package:flutter/material.dart';

import '../../../config/links.dart';
import '../../../domain/models/feedback.dart';
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
        ..showSnackBar(
          const SnackBar(content: Text('Thanks, we got your message.')),
        );
      viewModel.submit.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Help and feedback',
      children: [
        SettingsGroup(
          title: 'Tell us',
          children: [
            SettingsRow(
              label: FeedbackCategory.wrongAnswer.label,
              onTap: () => _openCategory(context, FeedbackCategory.wrongAnswer),
            ),
            SettingsRow(
              label: FeedbackCategory.bug.label,
              onTap: () => _openCategory(context, FeedbackCategory.bug),
            ),
            SettingsRow(
              label: FeedbackCategory.feature.label,
              onTap: () => _openCategory(context, FeedbackCategory.feature),
            ),
            const SettingsRow(label: 'Email us', value: email),
          ],
        ),
      ],
    );
  }
}
