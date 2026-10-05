import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import 'swipe_deck.dart';

class CardKicker extends StatelessWidget {
  const CardKicker({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = context.palette.textMuted;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: .8,
            ),
          ),
        ),
      ],
    );
  }
}

class CardTitle extends StatelessWidget {
  const CardTitle(this.text, {super.key, this.size = 24});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.display.copyWith(
        fontSize: size,
        height: 1.12,
        color: context.palette.text,
      ),
    );
  }
}

class RememberBox extends StatelessWidget {
  const RememberBox({
    super.key,
    required this.text,
    this.label = 'Remember',
    this.icon = Icons.priority_high_rounded,
  });

  final String text;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.tintCream,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: palette.edge, width: AppKeycap.borderWidth),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: palette.text),
                const SizedBox(width: 4),
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: palette.text,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: AppTextStyles.label.copyWith(
                color: palette.text,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardBody extends StatelessWidget {
  const CardBody({super.key, required this.children, this.tools});

  final List<Widget> children;
  final Widget? tools;

  @override
  Widget build(BuildContext context) {
    final tools = this.tools;
    return DeckCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
          if (tools != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: tools,
            ),
        ],
      ),
    );
  }
}

class CardTools extends StatelessWidget {
  const CardTools({
    super.key,
    required this.isKept,
    required this.onKeep,
    required this.onAsk,
  });

  final bool isKept;
  final VoidCallback onKeep;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Tool(
          icon: isKept ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          label: isKept ? 'Kept' : 'Keep',
          isOn: isKept,
          onTap: onKeep,
        ),
        const SizedBox(width: 8),
        _Tool(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Ask Pebby',
          onTap: onAsk,
        ),
      ],
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isOn = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ink = isOn ? AppColors.keycapEdge : palette.text;
    return Semantics(
      button: true,
      selected: isOn,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isOn ? AppColors.selected : palette.surfaceRaised,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: ink),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.labelStrong.copyWith(color: ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
