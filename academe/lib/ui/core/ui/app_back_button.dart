import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: SizedBox.square(
          dimension: 44,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: context.palette.text,
            ),
          ),
        ),
      ),
    );
  }
}
