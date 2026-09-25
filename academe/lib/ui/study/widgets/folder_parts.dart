import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
import '../../../utils/dates.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/pebby.dart';
import 'folders_view.dart';
import 'page_scaffold.dart';

class FolderHeader extends StatelessWidget {
  const FolderHeader({super.key, required this.folder});

  final FolderDetail folder;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final due = folder.summary.dueOn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const FolderIcon(size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.summary.name,
                    style: AppTextStyles.display.copyWith(
                      fontSize: 24,
                      height: 1.1,
                      color: palette.text,
                    ),
                  ),
                  Text(
                    due == null
                        ? 'No date'
                        : '${shortDay(due)} · ${dueLabel(due).toLowerCase()}',
                    style: AppTextStyles.caption.copyWith(
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (folder.chapters.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: folder.summary.progress / 100,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  color: palette.success,
                  backgroundColor: palette.surfaceRaised,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${folder.summary.progress}% ready',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class FolderEmpty extends StatelessWidget {
  const FolderEmpty({
    super.key,
    required this.onAddChapters,
    required this.onAddNote,
    this.onScanNotes,
  });

  final VoidCallback onAddChapters;
  final VoidCallback onAddNote;
  final VoidCallback? onScanNotes;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Center(
          child: SizedBox.square(
            dimension: 120,
            child: Pebby(pose: PebbyPose.think),
          ),
        ),
        Text(
          'What’s this folder for?',
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
            fontSize: 20,
            color: palette.text,
          ),
        ),
        Text(
          'Add chapters and Pebby plans your days.',
          textAlign: TextAlign.center,
          style: AppTextStyles.label.copyWith(color: palette.textMuted),
        ),
        const SizedBox(height: 16),
        AddOptions(
          onAddChapters: onAddChapters,
          onAddNote: onAddNote,
          onScanNotes: onScanNotes,
        ),
      ],
    );
  }
}

class AddOptions extends StatelessWidget {
  const AddOptions({
    super.key,
    required this.onAddChapters,
    required this.onAddNote,
    this.onScanNotes,
  });

  final VoidCallback onAddChapters;
  final VoidCallback onAddNote;
  final VoidCallback? onScanNotes;

  @override
  Widget build(BuildContext context) {
    final onScanNotes = this.onScanNotes;
    final plus = Icon(Icons.add_rounded, color: context.palette.text);
    return Column(
      children: [
        LinkRow(
          icon: Icons.menu_book_rounded,
          title: 'Add chapters',
          subtitle: 'From your syllabus',
          trailing: plus,
          onTap: onAddChapters,
        ),
        LinkRow(
          icon: Icons.edit_note_rounded,
          title: 'Write a note',
          subtitle: 'Anything you want to remember',
          trailing: plus,
          onTap: onAddNote,
        ),
        if (onScanNotes != null)
          LinkRow(
            icon: Icons.document_scanner_rounded,
            title: 'Scan notes',
            subtitle: 'Photos of pages, made into a lesson',
            trailing: plus,
            onTap: onScanNotes,
          ),
      ],
    );
  }
}

class AddTodoField extends StatefulWidget {
  const AddTodoField({super.key, required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  State<AddTodoField> createState() => _AddTodoFieldState();
}

class _AddTodoFieldState extends State<AddTodoField> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TextField(
      controller: _text,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _submit(),
      style: AppTextStyles.label.copyWith(color: palette.text),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Add a to-do',
        hintStyle: AppTextStyles.label.copyWith(color: palette.textMuted),
        prefixIcon: Icon(Icons.add_rounded, color: palette.textMuted),
        suffixIcon: IconButton(
          onPressed: _submit,
          tooltip: 'Add',
          icon: const Icon(
            Icons.arrow_upward_rounded,
            color: AppColors.primary,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
