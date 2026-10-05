import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';
import '../view_models/me_view_model.dart';
import 'settings_page.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({
    super.key,
    required this.viewModel,
    required this.onPick,
  });

  final MeViewModel viewModel;
  final ValueChanged<bool> onPick;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final isDark = viewModel.isDark;
        void pick(bool dark) {
          if (dark != isDark) onPick(dark);
        }

        return SettingsPage(
          title: 'Appearance',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
              child: Text(
                'THEME',
                style: AppTextStyles.caption.copyWith(
                  color: context.palette.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .8,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _ThemeKey(
                    label: 'Light',
                    icon: Icons.light_mode_rounded,
                    isSelected: !isDark,
                    onTap: () => pick(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ThemeKey(
                    label: 'Dark',
                    icon: Icons.dark_mode_rounded,
                    isSelected: isDark,
                    onTap: () => pick(true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Dark mode is easier on your eyes at night.',
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeKey extends StatelessWidget {
  const _ThemeKey({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = isSelected ? AppColors.keycapEdge : context.palette.text;
    return Semantics(
      selected: isSelected,
      label: label,
      child: Keycap(
        face: isSelected ? AppColors.selected : context.palette.surface,
        depth: 3,
        height: 96,
        isLatched: isSelected,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: ink, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelStrong.copyWith(
                fontSize: 16,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
