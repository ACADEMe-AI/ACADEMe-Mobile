import 'dart:io';

import 'package:flutter/material.dart';

import '../../../data/repositories/photo_repository.dart';
import '../../../domain/models/scan.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/screen_scale.dart';
import '../../study/widgets/folders_view.dart';
import '../../study/widgets/page_scaffold.dart';
import '../view_models/scan_flow_view_model.dart';
import 'scan_flow_screen.dart';
import 'scan_parts.dart';

class ScanPagesView extends StatelessWidget {
  const ScanPagesView({
    super.key,
    required this.pages,
    required this.isFull,
    required this.onAdd,
    required this.onRemove,
    required this.onRead,
  });

  final List<String> pages;
  final bool isFull;
  final ValueChanged<PhotoSource> onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final padding = ScreenScale.of(context).pagePadding;
    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 8, padding, 32),
      children: [
        Text(
          'Your pages',
          style: AppTextStyles.display.copyWith(
            fontSize: 24,
            color: palette.text,
          ),
        ),
        Text(
          '${pages.length} of ${ScanFlowViewModel.maxPages}',
          style: AppTextStyles.label.copyWith(color: palette.textMuted),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < pages.length; i++)
              _Page(path: pages[i], onRemove: () => onRemove(i)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Camera',
                isEnabled: !isFull,
                icon: Icon(Icons.photo_camera_rounded, color: palette.text),
                onTap: () => onAdd(PhotoSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Gallery',
                isEnabled: !isFull,
                icon: Icon(Icons.photo_library_rounded, color: palette.text),
                onTap: () => onAdd(PhotoSource.gallery),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppButton(
          label: pages.length == 1
              ? 'Read 1 page'
              : 'Read ${pages.length} pages',
          isPrimary: true,
          isEnabled: pages.isNotEmpty,
          onTap: onRead,
        ),
      ],
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: 88,
      height: 116,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: palette.edge, width: 2),
              image: DecorationImage(
                image: ResizeImage(FileImage(File(path)), width: 240),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              onPressed: onRemove,
              tooltip: 'Remove page',
              style: IconButton.styleFrom(backgroundColor: palette.surface),
              icon: Icon(Icons.close_rounded, size: 16, color: palette.text),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanNotesView extends StatefulWidget {
  const ScanNotesView({
    super.key,
    required this.scan,
    required this.pages,
    required this.folder,
    required this.onPickFolder,
    required this.onSave,
  });

  final Scan scan;
  final int pages;
  final FolderChoice? folder;
  final Future<FolderChoice?> Function() onPickFolder;
  final ValueChanged<NotesTarget> onSave;

  @override
  State<ScanNotesView> createState() => _ScanNotesViewState();
}

class _ScanNotesViewState extends State<ScanNotesView> {
  late FolderChoice? _folder = widget.folder;

  Future<FolderChoice?> _pick() async {
    final picked = await widget.onPickFolder();
    if (picked != null && mounted) setState(() => _folder = picked);
    return picked;
  }

  Future<void> _save({required bool makeLesson}) async {
    final folder = _folder ?? await _pick();
    if (folder == null) return;
    widget.onSave((folderId: folder.id, makeLesson: makeLesson));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final padding = ScreenScale.of(context).pagePadding;
    final folder = _folder;
    final chapter = widget.scan.chapter;
    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 8, padding, 32),
      children: [
        Text(
          switch (widget.pages) {
            0 => 'Your notes',
            1 => 'Pebby read 1 page',
            final n => 'Pebby read $n pages',
          },
          style: AppTextStyles.display.copyWith(
            fontSize: 24,
            color: palette.text,
          ),
        ),
        if (chapter.isNotEmpty)
          Text(
            chapter,
            style: AppTextStyles.label.copyWith(color: palette.textMuted),
          ),
        const SizedBox(height: 12),
        ScanTextBox(text: widget.scan.text),
        const SectionTitle('Where should these go?'),
        InkWell(
          onTap: _pick,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const FolderIcon(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    folder?.name ?? 'Choose a folder',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelStrong.copyWith(
                      color: palette.text,
                    ),
                  ),
                ),
                Text(
                  folder == null ? '' : 'Change',
                  style: AppTextStyles.labelStrong.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SectionTitle('Make from your notes'),
        LinkRow(
          icon: Icons.style_rounded,
          title: 'Swipe lesson',
          subtitle: 'Cards and quick checks, added to the plan',
          onTap: () => _save(makeLesson: true),
        ),
        LinkRow(
          icon: Icons.description_outlined,
          title: 'Just keep the notes',
          subtitle: 'The text goes into the folder',
          onTap: () => _save(makeLesson: false),
        ),
      ],
    );
  }
}
