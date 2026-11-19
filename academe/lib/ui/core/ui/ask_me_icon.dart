import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class AskMeIcon extends StatelessWidget {
  const AskMeIcon({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = size ?? theme.size ?? 24;
    return SizedBox.square(
      dimension: side,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.chat_bubble_rounded,
            size: side,
            color: theme.color ?? context.palette.text,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: side * .08),
            child: Icon(
              Icons.auto_awesome,
              size: side * .5,
              color: context.palette.surface,
            ),
          ),
        ],
      ),
    );
  }
}
