import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
import '../../../utils/dates.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/light_field.dart';
import '../view_models/folder_view_model.dart';

Future<T?> studySheet<T>(BuildContext context, Widget child) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.palette.surface,
      barrierColor: AppColors.keycapEdge.withValues(alpha: .35),
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: child,
      ),
    );

Future<DateTime?> pickStudyDate(BuildContext context, DateTime? initial) {
  final palette = context.palette;
  final today = dateOnly(DateTime.now());
  return showDatePicker(
    context: context,
    initialDate: initial ?? today.add(const Duration(days: 7)),
    firstDate: today,
    lastDate: today.add(const Duration(days: 730)),
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme:
            (palette.isDark
                    ? const ColorScheme.dark()
                    : const ColorScheme.light())
                .copyWith(
                  primary: AppColors.primary,
                  onPrimary: AppColors.onPrimary,
                  surface: palette.surface,
                  onSurface: palette.text,
                ),
      ),
      child: child!,
    ),
  );
}

class FolderSheet extends StatefulWidget {
  const FolderSheet({super.key, this.initial});

  final FolderSummary? initial;

  static Future<FolderEdit?> show(
    BuildContext context, {
    FolderSummary? initial,
  }) => studySheet(context, FolderSheet(initial: initial));

  @override
  State<FolderSheet> createState() => _FolderSheetState();
}

class _FolderSheetState extends State<FolderSheet> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late DateTime? _due = widget.initial?.dueOn;
  late bool _reminds = widget.initial?.reminds ?? true;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await pickStudyDate(context, _due);
    if (picked != null && mounted) setState(() => _due = picked);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final due = _due;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isEditing ? 'Edit folder' : 'New folder',
            style: AppTextStyles.display.copyWith(
              fontSize: 24,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 16),
          LightField(
            label: 'Name',
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: palette.border, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_rounded, color: palette.textMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        due == null ? 'Add a date' : shortDay(due),
                        style: AppTextStyles.label.copyWith(
                          fontSize: 16,
                          color: due == null ? palette.textMuted : palette.text,
                        ),
                      ),
                    ),
                    if (due == null)
                      Text(
                        'optional',
                        style: AppTextStyles.caption.copyWith(
                          color: palette.textMuted,
                        ),
                      )
                    else
                      IconButton(
                        onPressed: () => setState(() => _due = null),
                        tooltip: 'Remove date',
                        icon: Icon(
                          Icons.close_rounded,
                          color: palette.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _reminds,
              onChanged: (v) => setState(() => _reminds = v),
              activeThumbColor: AppColors.primary,
              title: Text(
                'Reminders for this folder',
                style: AppTextStyles.labelStrong.copyWith(color: palette.text),
              ),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: _isEditing ? 'Save' : 'Create',
            isPrimary: true,
            isEnabled: _name.text.trim().isNotEmpty,
            onTap: () => Navigator.of(
              context,
            ).pop((name: _name.text, dueOn: _due, reminds: _reminds)),
          ),
        ],
      ),
    );
  }
}

class NoteSheet extends StatefulWidget {
  const NoteSheet({super.key, required this.title, required this.action});

  final String title;
  final String action;

  static Future<String?> show(
    BuildContext context, {
    String title = 'Write a note',
    String action = 'Save note',
  }) => studySheet(context, NoteSheet(title: title, action: action));

  @override
  State<NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<NoteSheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: AppTextStyles.display.copyWith(
              fontSize: 24,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _text,
            autofocus: true,
            minLines: 3,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.input.copyWith(color: palette.text),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'Type here…',
              hintStyle: AppTextStyles.input.copyWith(color: palette.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide(color: palette.border, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide(color: palette.border, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: widget.action,
            isPrimary: true,
            isEnabled: _text.text.trim().isNotEmpty,
            onTap: () => Navigator.of(context).pop(_text.text),
          ),
        ],
      ),
    );
  }
}
