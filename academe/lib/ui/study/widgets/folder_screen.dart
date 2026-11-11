import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/screen_scale.dart';
import '../study_actions.dart';
import '../view_models/folder_view_model.dart';
import '../view_models/study_view_model.dart';
import 'add_chapters_screen.dart';
import 'folder_parts.dart';
import 'folder_sheets.dart';
import 'page_scaffold.dart';
import 'plan_screen.dart';
import 'task_row.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({
    super.key,
    required this.viewModel,
    required this.study,
    required this.actions,
    this.onReminders,
    this.onScanNotes,
  });

  final FolderViewModel viewModel;
  final StudyViewModel study;
  final StudyActions actions;
  final VoidCallback? onReminders;
  final void Function(String id, String name)? onScanNotes;

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  FolderViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load.execute();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _addChapters() async {
    final picked = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => AddChaptersScreen(
          viewModel: widget.study,
          alreadyIn: _viewModel.chapterIds,
        ),
      ),
    );
    if (picked != null) await _viewModel.addChapters(picked);
  }

  Future<void> _addNote() async {
    final text = await NoteSheet.show(context);
    if (text != null) await _viewModel.addNote(text);
  }

  Future<void> _edit() async {
    final summary = _viewModel.detail?.summary;
    if (summary == null) return;
    final edit = await FolderSheet.show(context, initial: summary);
    if (edit == null) return;
    await _viewModel.edit.execute(edit);
    if (edit.reminds) widget.onReminders?.call();
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.folderDeleteTitle),
        content: Text(l10n.folderDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.studyKeep),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.studyDelete),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await _viewModel.delete.execute();
    if (mounted && _viewModel.delete.isCompleted) Navigator.of(context).pop();
  }

  Future<void> _openNote(FolderNote note) async {
    final l10n = context.l10n;
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(child: Text(note.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.studyDelete),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionClose),
          ),
        ],
      ),
    );
    if (remove == true) await _viewModel.removeItem(note.itemId);
  }

  VoidCallback? get _scanNotes {
    final scan = widget.onScanNotes;
    final summary = _viewModel.detail?.summary;
    if (scan == null || summary == null) return null;
    return () => scan(summary.id, summary.name);
  }

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final detail = _viewModel.detail;
        return StudyPage(
          title: l10n.folderTitle,
          actions: [
            IconButton(
              onPressed: _edit,
              tooltip: l10n.folderEditRemindersTooltip,
              icon: Icon(
                detail?.summary.reminds ?? true
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_outlined,
              ),
              color: detail?.summary.reminds ?? true
                  ? AppColors.primary
                  : context.palette.textMuted,
            ),
            IconButton(
              onPressed: _delete,
              tooltip: l10n.folderDeleteTooltip,
              icon: const Icon(Icons.delete_outline_rounded),
              color: context.palette.errorInk,
            ),
          ],
          child: detail == null
              ? Center(
                  child: _viewModel.load.hasError
                      ? TextButton(
                          onPressed: _viewModel.load.execute,
                          child: Text(l10n.folderLoadError),
                        )
                      : const CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, 32),
                  children: [
                    FolderHeader(folder: detail),
                    if (detail.isEmpty)
                      FolderEmpty(
                        onAddChapters: _addChapters,
                        onAddNote: _addNote,
                        onScanNotes: _scanNotes,
                      )
                    else
                      _FolderBody(
                        detail: detail,
                        viewModel: _viewModel,
                        actions: widget.actions,
                        onAddChapters: _addChapters,
                        onAddNote: _addNote,
                        onOpenNote: _openNote,
                        onScanNotes: _scanNotes,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _FolderBody extends StatelessWidget {
  const _FolderBody({
    required this.detail,
    required this.viewModel,
    required this.actions,
    required this.onAddChapters,
    required this.onAddNote,
    required this.onOpenNote,
    required this.onScanNotes,
  });

  final FolderDetail detail;
  final FolderViewModel viewModel;
  final StudyActions actions;
  final VoidCallback onAddChapters;
  final VoidCallback onAddNote;
  final ValueChanged<FolderNote> onOpenNote;
  final VoidCallback? onScanNotes;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final minutes = detail.today
        .where((t) => !t.isDone)
        .fold(0, (sum, t) => sum + t.minutes);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          minutes > 0 ? l10n.folderTodayMinutes(minutes) : l10n.studyToday,
          trailing: detail.plan.isEmpty
              ? null
              : TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlanScreen(folder: detail),
                    ),
                  ),
                  child: Text(l10n.folderSeePlan),
                ),
        ),
        if (detail.today.isEmpty)
          Text(
            detail.summary.dueOn == null && detail.chapters.isEmpty
                ? l10n.folderAddChaptersOrTodos
                : l10n.folderNothingLeftForToday,
            style: AppTextStyles.label.copyWith(color: palette.textMuted),
          ),
        for (final task in detail.today)
          TaskRow(
            task: task,
            onOpen: () => actions.openTask(task),
            onToggle: () => viewModel.toggleTodo(task),
          ),
        const SizedBox(height: 8),
        AddTodoField(onAdd: viewModel.addTodo),
        SectionTitle(
          l10n.folderInThisFolder,
          trailing: TextButton(
            onPressed: onAddChapters,
            child: Text(l10n.folderAddChapters),
          ),
        ),
        for (final c in detail.chapters)
          LinkRow(
            icon: Icons.menu_book_rounded,
            title: l10n.studyChTitle(c.number, c.title),
            subtitle: l10n.studyLessonsDoneOf(c.lessonsDone, c.lessons),
            onTap: () => actions.openChapter(c.chapterId),
          ),
        for (final l in detail.lessons)
          LinkRow(
            icon: Icons.style_rounded,
            title: l.title,
            subtitle: l.isDone
                ? l10n.folderFromNotesDone
                : l10n.folderFromNotesMinutes(l.minutes),
            onTap: () => actions.openLesson(l.deckId),
          ),
        for (final n in detail.notes)
          LinkRow(
            icon: Icons.description_outlined,
            title: n.text.split('\n').first,
            subtitle: l10n.folderNote,
            onTap: () => onOpenNote(n),
          ),
        const SizedBox(height: 8),
        AddOptions(
          onAddChapters: onAddChapters,
          onAddNote: onAddNote,
          onScanNotes: onScanNotes,
        ),
      ],
    );
  }
}
