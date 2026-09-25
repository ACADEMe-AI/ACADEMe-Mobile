import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/screen_scale.dart';
import '../view_models/study_view_model.dart';
import 'page_scaffold.dart';
import 'pill_choices.dart';
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

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    final palette = context.palette;
    final chapters = [
      for (final c in widget.viewModel.allChapters)
        if (!c.isComingSoon) c,
    ];
    final subjects = [
      for (final s in widget.viewModel.subjects)
        if (chapters.any((c) => c.subject == s.id)) s,
    ];
    final subject = _subject ?? subjects.firstOrNull?.id;
    return StudyPage(
      title: 'Add chapters',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, 16),
              children: [
                if (chapters.isEmpty)
                  const StudyNote('No chapters for your class yet.')
                else
                  PillChoices(
                    choices: [for (final s in subjects) (s.id, s.name)],
                    selected: subject,
                    onSelect: (id) => setState(() => _subject = id),
                  ),
                const SizedBox(height: 8),
                for (final c in chapters)
                  if (c.subject == subject)
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
