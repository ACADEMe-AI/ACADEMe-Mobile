import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: context.palette.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: .8,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: context.palette.edge,
              width: AppKeycap.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: context.palette.edge,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.palette.surfaceRaised,
                  ),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.value,
    this.onTap,
    this.trailing,
    this.isDanger = false,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelStrong.copyWith(
                    color: isDanger ? AppColors.error : context.palette.text,
                  ),
                ),
              ),
              if (value case final text?)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    text,
                    style: AppTextStyles.label.copyWith(
                      color: context.palette.textMuted,
                    ),
                  ),
                ),
              if (trailing case final widget?)
                widget
              else if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.palette.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: SettingsRow(
        label: label,
        onTap: () => onChanged(!value),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: context.palette.surface,
          activeTrackColor: AppColors.primary,
          inactiveThumbColor: context.palette.surface,
          inactiveTrackColor: context.palette.border,
          trackOutlineColor: WidgetStatePropertyAll(context.palette.border),
        ),
      ),
    );
  }
}
