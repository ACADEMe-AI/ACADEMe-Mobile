import 'package:flutter/material.dart';

import 'settings_list.dart';
import 'settings_page.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const email = 'support@academe.cc';

  @override
  Widget build(BuildContext context) {
    void soon() => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Write to us at $email')));
    return SettingsPage(
      title: 'Help and feedback',
      children: [
        SettingsGroup(
          title: 'Tell us',
          children: [
            SettingsRow(label: 'Report a wrong answer', onTap: soon),
            SettingsRow(label: 'Something isn’t working', onTap: soon),
            SettingsRow(label: 'Suggest a feature', onTap: soon),
            const SettingsRow(label: 'Email us', value: email),
          ],
        ),
      ],
    );
  }
}
