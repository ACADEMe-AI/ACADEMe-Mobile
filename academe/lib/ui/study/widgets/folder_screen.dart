import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
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
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this folder?'),
        content: const Text(
          'Its notes and to-dos go too. Your lessons and progress stay.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await _viewModel.delete.execute();
    if (mounted && _viewModel.delete.isCompleted) Navigator.of(context).pop();
  }

  Future<void> _openNote(FolderNote note) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(child: Text(note.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Close'),
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
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final detail = _viewModel.detail;
        return StudyPage(
          title: 'Folder',
          actions: [
            IconButton(
              onPressed: _edit,
              tooltip: 'Edit and reminders',
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
              tooltip: 'Delete folder',
              icon: const Icon(Icons.delete_outline_rounded),
              color: context.palette.errorInk,
            ),
          ],
          child: detail == null
              ? Center(
                  child: _viewModel.load.hasError
                      ? TextButton(
                          onPressed: _viewModel.load.execute,
                          child: const Text('Couldn’t load this folder. Retry'),
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
    final minutes = detail.today
        .where((t) => !t.isDone)
        .fold(0, (sum, t) => sum + t.minutes);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          minutes > 0 ? 'Today · $minutes min' : 'Today',
          trailing: detail.plan.isEmpty
              ? null
              : TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlanScreen(folder: detail),
                    ),
                  ),
                  child: const Text('See plan'),
                ),
        ),
        if (detail.today.isEmpty)
          Text(
            detail.summary.dueOn == null && detail.chapters.isEmpty
                ? 'Add chapters or to-dos.'
                : 'Nothing left for today.',
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
          'In this folder',
          trailing: TextButton(
            onPressed: onAddChapters,
            child: const Text('Add chapters'),
          ),
        ),
        for (final c in detail.chapters)
          LinkRow(
            icon: Icons.menu_book_rounded,
            title: 'Ch ${c.number} · ${c.title}',
            subtitle: '${c.lessonsDone} of ${c.lessons} lessons done',
            onTap: () => actions.openChapter(c.chapterId),
          ),
        for (final l in detail.lessons)
          LinkRow(
            icon: Icons.style_rounded,
            title: l.title,
            subtitle: l.isDone
                ? 'From your notes · done'
                : 'From your notes · ${l.minutes} min',
            onTap: () => actions.openLesson(l.deckId),
          ),
        for (final n in detail.notes)
          LinkRow(
            icon: Icons.description_outlined,
            title: n.text.split('\n').first,
            subtitle: 'Note',
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
