import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/study_stream.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/page_dots.dart';
import '../../core/ui/subject_icons.dart';

class StreamCards extends StatefulWidget {
  const StreamCards({
    super.key,
    required this.streams,
    required this.index,
    required this.onChanged,
  });

  final List<StudyStream> streams;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  State<StreamCards> createState() => _StreamCardsState();
}

class _StreamCardsState extends State<StreamCards> {
  late final _pages = PageController(
    viewportFraction: .5,
    initialPage: widget.index,
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    widget.onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final streams = widget.streams;
    final last = streams.length - 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 196,
          child: PageView.builder(
            controller: _pages,
            itemCount: streams.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) => _StreamCard(
              stream: streams[index],
              tint: context.palette.tints[index % 5],
              onTap: () => _pages.animateToPage(
                index,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        PageDots(count: streams.length, active: widget.index),
        const SizedBox(height: 8),
        Text(
          widget.index < last
              ? 'Swipe for ${streams[last].name}. Change it any time in Me.'
              : 'Change it any time in Me.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: context.palette.textMuted,
          ),
        ),
      ],
    );
  }
}

class _StreamCard extends StatelessWidget {
  const _StreamCard({
    required this.stream,
    required this.tint,
    required this.onTap,
  });

  final StudyStream stream;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: palette.edge,
              width: AppKeycap.borderWidth,
            ),
            boxShadow: [
              BoxShadow(color: palette.edge, offset: const Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  SubjectIcons.stream(stream.id),
                  size: 36,
                  color: palette.text,
                ),
                const SizedBox(height: 8),
                Text(
                  stream.name,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display.copyWith(
                    fontSize: 19,
                    color: palette.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stream.summary,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
