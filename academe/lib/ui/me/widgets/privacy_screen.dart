import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/links.dart';
import '../../core/themes/app_theme.dart';
import 'settings_list.dart';
import 'settings_page.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const summary = [
    'We keep your account, class and board, study progress, folders, notes '
        'and chats with Pebby to run ACADEMe for you.',
    'Your questions and scanned photos go to Sarvam AI in India so Pebby can '
        'answer. We don’t store your photos, only the text read from them.',
    'No ads, no advertising ID, no location, and we never sell your data.',
    'Delete your account any time in Account. Everything is erased after '
        '30 days.',
  ];

  @override
  Widget build(BuildContext context) {
    Future<void> open(Uri link) async {
      final opened = await launchUrl(
        link,
        mode: LaunchMode.externalApplication,
      );
      if (opened || !context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Open $link in your browser')));
    }

    return SettingsPage(
      title: 'Privacy and terms',
      children: [
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.palette.tintCream,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in summary)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      line,
                      style: AppTextStyles.label.copyWith(
                        color: context.palette.text,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SettingsGroup(
          title: 'Documents',
          children: [
            SettingsRow(
              label: 'Privacy policy',
              onTap: () => open(Links.privacy),
            ),
            SettingsRow(label: 'Terms of use', onTap: () => open(Links.terms)),
          ],
        ),
        SettingsGroup(
          title: 'Your data',
          children: [
            SettingsRow(
              label: 'Get a copy of my data',
              onTap: () => open(Links.support),
            ),
            SettingsRow(
              label: 'Grievance Officer',
              onTap: () => open(Links.support.replace(fragment: 'grievance')),
            ),
            const SettingsRow(label: 'Email', value: Links.supportEmail),
          ],
        ),
      ],
    );
  }
}
