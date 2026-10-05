import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/models/app_language.dart';
import '../../../utils/result.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/pebby.dart';
import '../view_models/me_view_model.dart';

class LanguageSwitchScreen extends StatefulWidget {
  const LanguageSwitchScreen({
    super.key,
    required this.viewModel,
    required this.language,
  });

  final MeViewModel viewModel;
  final AppLanguage language;

  static const minimum = Duration(milliseconds: 1800);

  @override
  State<LanguageSwitchScreen> createState() => _LanguageSwitchScreenState();
}

class _LanguageSwitchScreenState extends State<LanguageSwitchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: LanguageSwitchScreen.minimum,
  )..forward();

  @override
  void initState() {
    super.initState();
    _switch();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _switch() async {
    final command = widget.viewModel.saveLanguage;
    await Future.wait([
      command.execute(widget.language),
      Future<void>.delayed(LanguageSwitchScreen.minimum),
    ]);
    if (!mounted) return;
    Navigator.of(context).pop(command.result is Ok);
  }

  @override
  Widget build(BuildContext context) {
    final language = widget.language;
    return AnnotatedRegion(
      value: context.palette.systemBars,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: context.palette.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox.square(
                    dimension: 220,
                    child: Pebby(pose: PebbyPose.working),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Switching to ${language.nativeName}…',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display.copyWith(
                      fontSize: 24,
                      color: context.palette.text,
                    ),
                  ),
                  if (language != AppLanguage.english)
                    Text(
                      'Switching to ${language.englishName}',
                      style: AppTextStyles.label.copyWith(
                        color: context.palette.textMuted,
                      ),
                    ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) => LinearProgressIndicator(
                      value: Curves.easeInOut.transform(_progress.value),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      color: AppColors.primary,
                      backgroundColor: context.palette.surfaceRaised,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
