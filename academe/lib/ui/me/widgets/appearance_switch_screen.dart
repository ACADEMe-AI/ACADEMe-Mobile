import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/pebby.dart';
import '../view_models/me_view_model.dart';

class AppearanceSwitchScreen extends StatefulWidget {
  const AppearanceSwitchScreen({
    super.key,
    required this.viewModel,
    required this.isDark,
  });

  final MeViewModel viewModel;
  final bool isDark;

  static const minimum = Duration(milliseconds: 3000);
  static const switchAt = Duration(milliseconds: 1200);

  @override
  State<AppearanceSwitchScreen> createState() => _AppearanceSwitchScreenState();
}

class _AppearanceSwitchScreenState extends State<AppearanceSwitchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: AppearanceSwitchScreen.minimum,
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
    await Future<void>.delayed(AppearanceSwitchScreen.switchAt);
    await widget.viewModel.setDark(widget.isDark);
    await Future<void>.delayed(
      AppearanceSwitchScreen.minimum - AppearanceSwitchScreen.switchAt,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
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
                  SizedBox.square(
                    dimension: 220,
                    child: Pebby(
                      pose: isDark ? PebbyPose.sleep : PebbyPose.wakeUp,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isDark ? 'Lights off…' : 'Good morning!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display.copyWith(
                      fontSize: 24,
                      color: context.palette.text,
                    ),
                  ),
                  Text(
                    isDark
                        ? 'Pebby is dimming the room'
                        : 'Pebby is opening the curtains',
                    textAlign: TextAlign.center,
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
