import 'package:flutter/material.dart';

import '../../../domain/models/pro.dart';
import '../../../routing/routes.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';
import '../view_models/pro_view_model.dart';

class ProCard extends StatelessWidget {
  const ProCard({super.key, required this.viewModel});

  final ProViewModel viewModel;

  static const height = 72.0;

  String _subtitle(ProViewModel viewModel) {
    if (!viewModel.isPro) return 'Free plan · go unlimited with Pro';
    return switch (viewModel.plan.period) {
      ProPeriod.monthly => 'Pro · monthly',
      ProPeriod.annual => 'Pro · annual',
      null => 'Pro',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final isPro = viewModel.isPro;
        final ink = isPro ? context.palette.text : AppColors.keycapEdge;
        return Keycap(
          face: isPro ? context.palette.tintLavender : AppColors.selected,
          depth: AppKeycap.optionDepth,
          height: height,
          onTap: () => Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(isPro ? Routes.proManage : Routes.paywall),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: ink, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACADEMe Pro',
                        style: AppTextStyles.labelStrong.copyWith(color: ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle(viewModel),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(color: ink),
                      ),
                    ],
                  ),
                ),
                Text(
                  isPro ? 'Manage' : 'Go Pro',
                  style: AppTextStyles.labelStrong.copyWith(color: ink),
                ),
                Icon(Icons.chevron_right_rounded, color: ink),
              ],
            ),
          ),
        );
      },
    );
  }
}
