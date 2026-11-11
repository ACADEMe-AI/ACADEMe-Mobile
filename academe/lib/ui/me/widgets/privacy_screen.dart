import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/links.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import 'settings_list.dart';
import 'settings_page.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static List<String> summary(AppLocalizations l10n) => [
    l10n.privacySummary1,
    l10n.privacySummary2,
    l10n.privacySummary3,
    l10n.privacySummary4,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Future<void> open(Uri link) async {
      final opened = await launchUrl(
        link,
        mode: LaunchMode.externalApplication,
      );
      if (opened || !context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.meOpenInBrowser('$link'))),
        );
    }

    return SettingsPage(
      title: l10n.mePrivacyAndTerms,
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
                for (final line in summary(l10n))
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
          title: l10n.privacyDocuments,
          children: [
            SettingsRow(
              label: l10n.privacyPolicy,
              onTap: () => open(Links.privacy),
            ),
            SettingsRow(
              label: l10n.privacyTermsOfUse,
              onTap: () => open(Links.terms),
            ),
          ],
        ),
        SettingsGroup(
          title: l10n.privacyYourData,
          children: [
            SettingsRow(
              label: l10n.privacyGetCopy,
              onTap: () => open(Links.support),
            ),
            SettingsRow(
              label: l10n.privacyGrievanceOfficer,
              onTap: () => open(Links.support.replace(fragment: 'grievance')),
            ),
            SettingsRow(label: l10n.authEmail, value: Links.supportEmail),
          ],
        ),
      ],
    );
  }
}
