import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/ui/pebby.dart';
import '../view_models/sign_up_view_model.dart';

class SignUpPebby extends StatelessWidget {
  const SignUpPebby({
    super.key,
    required this.viewModel,
    required this.isPasswordHidden,
  });

  final SignUpViewModel viewModel;
  final ValueListenable<bool> isPasswordHidden;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        viewModel,
        viewModel.connectProvider,
        viewModel.createAccount,
        viewModel.saveName,
        isPasswordHidden,
      ]),
      builder: (context, _) => Pebby(
        pose: poseFor(viewModel, isPasswordHidden: isPasswordHidden.value),
      ),
    );
  }

  static double poseFor(
    SignUpViewModel viewModel, {
    required bool isPasswordHidden,
  }) {
    if (viewModel.connectProvider.isRunning ||
        viewModel.createAccount.isRunning ||
        viewModel.saveName.isRunning) {
      return PebbyPose.think;
    }
    double watching(String typed) =>
        typed.isEmpty ? PebbyPose.happy : PebbyPose.focused;

    return switch (viewModel.step) {
      SignUpStep.hello when viewModel.failure != null => PebbyPose.encourage,
      SignUpStep.hello => PebbyPose.wave,
      SignUpStep.firstName => watching(viewModel.firstName),
      SignUpStep.lastName => watching(viewModel.lastName),
      SignUpStep.email =>
        viewModel.emailProblem != EmailProblem.none
            ? PebbyPose.encourage
            : watching(viewModel.email),
      SignUpStep.password =>
        viewModel.failure != null
            ? PebbyPose.encourage
            : isPasswordHidden
            ? PebbyPose.coverEyes
            : PebbyPose.shy,
      SignUpStep.done => PebbyPose.celebrateBig,
    };
  }
}
