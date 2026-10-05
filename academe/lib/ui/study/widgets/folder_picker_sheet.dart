import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import 'folder_sheets.dart';
import 'folders_view.dart';

class FolderPickerSheet extends StatelessWidget {
  const FolderPickerSheet({super.key, required this.folders});

  final List<FolderSummary> folders;

  static const newFolder = '';

  static Future<String?> show(
    BuildContext context, {
    required List<FolderSummary> folders,
  }) => studySheet(context, FolderPickerSheet(folders: folders));

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .7,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text(
            'Add to a folder',
            style: AppTextStyles.display.copyWith(
              fontSize: 24,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 12),
          for (final folder in folders)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FolderTile(
                folder: folder,
                onTap: () => Navigator.of(context).pop(folder.id),
              ),
            ),
          AppButton(
            label: 'New folder',
            icon: Icon(Icons.create_new_folder_outlined, color: palette.text),
            onTap: () => Navigator.of(context).pop(newFolder),
          ),
        ],
      ),
    );
  }
}
