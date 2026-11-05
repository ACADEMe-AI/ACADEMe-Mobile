part of 'pro_manage_screen.dart';

class _ManageFooter extends StatelessWidget {
  const _ManageFooter({
    required this.isPro,
    required this.notice,
    required this.onGoPro,
    required this.onManage,
    required this.onRestore,
  });

  final bool isPro;
  final String? notice;
  final VoidCallback onGoPro;
  final VoidCallback onManage;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surface,
        border: Border(top: BorderSide(color: context.palette.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isPro)
                AppButton(
                  label: 'Go Pro · 3× limits',
                  isPrimary: true,
                  onTap: onGoPro,
                )
              else ...[
                AppButton(
                  label: 'Manage in Google Play',
                  isPrimary: true,
                  onTap: onManage,
                ),
                TextButton(
                  onPressed: onRestore,
                  child: Text(
                    'Restore purchases',
                    style: AppTextStyles.labelStrong.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              if (notice case final text?)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: context.palette.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
