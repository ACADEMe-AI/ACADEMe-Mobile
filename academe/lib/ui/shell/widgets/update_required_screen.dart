import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/environment.dart';
import '../../../domain/models/app_config.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/pebby.dart';

class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key, required this.config});

  final AppConfig config;

  Future<void> _openStore() async {
    final url = config.updateUrl;
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = config.updateMessage.isNotEmpty
        ? config.updateMessage
        : 'New version just dropped, you don\'t wanna miss this!';
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              SizedBox(
                height: 140,
                child: Semantics(
                  label: 'Pebby',
                  child: const Pebby(pose: PebbyPose.headSway),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hold up',
                textAlign: TextAlign.center,
                style: AppTextStyles.sheetTitle.copyWith(
                  color: AppColors.lightText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelStrong.copyWith(
                  color: AppColors.lightText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This build can’t talk to our servers anymore. '
                'Update on Play to keep studying.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Installed build ${Environment.buildNumber}.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Update on Google Play',
                onTap: _openStore,
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
