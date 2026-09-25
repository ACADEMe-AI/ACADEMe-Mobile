import 'package:flutter/material.dart';

import '../../../data/repositories/photo_repository.dart';
import '../../../domain/models/chat.dart';
import '../../../domain/models/scan.dart';
import '../../scan/view_models/scan_flow_view_model.dart';
import '../../scan/widgets/check_result_screen.dart';
import '../../scan/widgets/scan_flow_screen.dart';
import '../../scan/widgets/scan_parts.dart';
import 'app_shell.dart';

mixin ScanNavigation on State<AppShell> {
  static const _maxAsk = 1900;

  void showMessage(String message);

  void openFolder(String folderId);

  Future<FolderChoice?> pickFolder();

  void askPebby(ChatMode mode, String text, {ValueChanged<String>? onThread});

  void openThread(ChatThread thread);

  Future<void> startScan(
    ScanMode mode, {
    PhotoSource? source,
    FolderChoice? folder,
  }) async {
    final from = source ?? await ScanSourceSheet.show(context, mode);
    if (from == null || !mounted) return;
    final flow = widget.scans.flow(mode);
    await flow.addPages.execute(from);
    if (!mounted || flow.pages.isEmpty) {
      if (flow.addPages.hasError && mounted) {
        showMessage('Couldn’t open the camera. Try the gallery.');
      }
      flow.dispose();
      return;
    }
    _pushFlow(flow, folder: folder);
  }

  void _pushFlow(ScanFlowViewModel flow, {FolderChoice? folder}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScanFlowScreen(
          viewModel: flow,
          folder: folder,
          onSolve: (scan, text) => _toAskMe(ChatMode.solve, scan, text),
          onAsk: (scan, text) => _toAskMe(ChatMode.explain, scan, text),
          onMarked: (scan, marking) => _showMarks(scan, marking, replace: true),
          onPickFolder: pickFolder,
          onSaved: (folderId) {
            Navigator.of(context).pop();
            openFolder(folderId);
          },
        ),
      ),
    );
  }

  void _toAskMe(ChatMode mode, Scan scan, String text) {
    final clipped = String.fromCharCodes(text.runes.take(_maxAsk));
    askPebby(
      mode,
      clipped,
      onThread: (threadId) =>
          widget.scans.scanRepository.linkThread(scan.id, threadId),
    );
  }

  void _showMarks(Scan scan, Marking marking, {bool replace = false}) {
    final route = MaterialPageRoute<void>(
      builder: (_) => CheckResultScreen(
        marking: marking,
        chapter: scan.chapter,
        onAskPebby: () => askPebby(
          ChatMode.explain,
          String.fromCharCodes(
            [
              if (marking.question.isNotEmpty) 'Question: ${marking.question}',
              'My answer:\n${scan.text}',
              'I got ${marking.awarded}/${marking.marks}. '
                  'How do I get full marks?',
            ].join('\n\n').runes.take(_maxAsk),
          ),
        ),
        onCheckAgain: () {
          Navigator.of(context).pop();
          startScan(ScanMode.check);
        },
      ),
    );
    final navigator = Navigator.of(context);
    replace ? navigator.pushReplacement(route) : navigator.push(route);
  }

  void openScan(Scan scan) {
    final result = scan.result;
    final threadId = scan.threadId;
    final folderId = scan.folderId;
    if (result != null) {
      _showMarks(scan, result);
    } else if (threadId != null) {
      openThread(
        ChatThread(
          id: threadId,
          mode: scan.mode == ScanMode.solve ? ChatMode.solve : ChatMode.explain,
          title: scan.title,
          updatedAt: scan.createdAt,
        ),
      );
    } else if (folderId != null) {
      openFolder(folderId);
    } else {
      _pushFlow(widget.scans.flow(scan.mode, scan: scan));
    }
  }
}
