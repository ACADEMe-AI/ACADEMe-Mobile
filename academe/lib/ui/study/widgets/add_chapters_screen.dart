import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/screen_scale.dart';
import '../view_models/study_view_model.dart';
import 'active_filter_chips.dart';
import 'page_scaffold.dart';
import 'pill_choices.dart';
import 'status_filter_row.dart';
import 'study_note.dart';

class AddChaptersScreen extends StatefulWidget {
  const AddChaptersScreen({
    super.key,
    required this.viewModel,
    required this.alreadyIn,
  });

  final StudyViewModel viewModel;
  final List<String> alreadyIn;

  @override
  State<AddChaptersScreen> createState() => _AddChaptersScreenState();
}

class _AddChaptersScreenState extends State<AddChaptersScreen> {
  final _picked = <String>{};
  String? _subject;
  ChapterFilter _status = ChapterFilter.all;
  ChapterFilters _filters = const ChapterFilters();

  List<StudyChapter> _chaptersWith(String? subject, ChapterFilters filters) => [
    for (final c in widget.viewModel.chaptersFor(subject, _status, filters))
      if (!c.isComingSoon) c,
  ];

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    final palette = context.palette;
    final ready = [
      for (final c in widget.viewModel.allChapters)
        if (!c.isComingSoon) c.subject,
    ];
    final subjects = [
      for (final s in widget.viewModel.subjects)
        if (ready.contains(s.id)) s,
    ];
    final subject = _subject ?? subjects.firstOrNull?.id;
    final chapters = _chaptersWith(subject, _filters);
    return StudyPage(
      title: 'Add chapters',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, 16),
              children: [
                if (subjects.isEmpty)
                  const StudyNote('No chapters for your class yet.')
                else ...[
                  PillChoices(
                    choices: [for (final s in subjects) (s.id, s.name)],
                    selected: subject,
                    onSelect: (id) => setState(() => _subject = id),
                    isOneRow: true,
                  ),
                  const SizedBox(height: 8),
                  StatusFilterRow(
                    status: _status,
                    onStatus: (status) => setState(() => _status = status),
                    filters: _filters,
                    onFilters: (filters) => setState(() => _filters = filters),
                    count: (filters) => _chaptersWith(subject, filters).length,
                  ),
                  if (!_filters.isEmpty)
                    ActiveFilterChips(
                      filters: _filters,
                      onChanged: (filters) =>
                          setState(() => _filters = filters),
                      count: chapters.length,
                    ),
                ],
                const SizedBox(height: 8),
                for (final c in chapters)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value:
                        widget.alreadyIn.contains(c.id) ||
                        _picked.contains(c.id),
                    onChanged: widget.alreadyIn.contains(c.id)
                        ? null
                        : (on) => setState(
                            () => on == true
                                ? _picked.add(c.id)
                                : _picked.remove(c.id),
                          ),
                    activeColor: AppColors.primary,
                    side: BorderSide(color: palette.edge, width: 2),
                    title: Text(
                      'Ch ${c.number} · ${c.title}',
                      style: AppTextStyles.labelStrong.copyWith(
                        color: palette.text,
                      ),
                    ),
                    subtitle: Text(
                      widget.alreadyIn.contains(c.id)
                          ? 'Already in this folder'
                          : '${c.lessons.length} lessons · ${c.lessonsDone} done',
                      style: AppTextStyles.caption.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, 16),
            child: AppButton(
              label: _picked.isEmpty
                  ? 'Pick chapters'
                  : 'Add ${_picked.length} chapter${_picked.length == 1 ? '' : 's'}',
              isPrimary: true,
              isEnabled: _picked.isNotEmpty,
              onTap: () => Navigator.of(context).pop(_picked.toList()),
            ),
          ),
        ],
      ),
    );
  }
}
