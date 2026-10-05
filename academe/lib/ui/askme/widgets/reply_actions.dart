import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/chat.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/report_button.dart';

class ReplyActions extends StatelessWidget {
  const ReplyActions({
    super.key,
    required this.message,
    required this.onRate,
    required this.onRetry,
    required this.onReport,
  });

  final ChatMessage message;
  final ValueChanged<int> onRate;
  final VoidCallback? onRetry;
  final ReportAnswer onReport;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionIcon(
          icon: message.rating == 1
              ? Icons.thumb_up_alt_rounded
              : Icons.thumb_up_alt_outlined,
          tooltip: 'Helpful',
          isOn: message.rating == 1,
          onTap: () => onRate(1),
        ),
        _ActionIcon(
          icon: message.rating == -1
              ? Icons.thumb_down_alt_rounded
              : Icons.thumb_down_alt_outlined,
          tooltip: 'Not helpful',
          isOn: message.rating == -1,
          onTap: () => onRate(-1),
        ),
        _ActionIcon(
          icon: Icons.content_copy_rounded,
          tooltip: 'Copy',
          onTap: () {
            Clipboard.setData(ClipboardData(text: message.body));
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Copied')));
          },
        ),
        if (onRetry case final retry?)
          _ActionIcon(
            icon: Icons.refresh_rounded,
            tooltip: 'Try again',
            onTap: retry,
          ),
        ReportButton(
          title: 'Report this answer',
          thanks: 'Thanks. We’ll review this answer.',
          onReport: onReport,
          iconSize: 18,
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isOn = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      color: isOn ? AppColors.primary : context.palette.textMuted,
      icon: Icon(icon),
    );
  }
}
