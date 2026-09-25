import 'package:flutter/material.dart';

import '../../../data/repositories/photo_repository.dart';
import '../../../domain/models/scan.dart';
import '../../../routing/routes.dart';
import '../../../utils/result.dart';
import '../../paywall/widgets/limit_sheet.dart';
import '../../study/widgets/page_scaffold.dart';
import '../view_models/scan_flow_view_model.dart';
import 'scan_notes_view.dart';
import 'scan_parts.dart';
import 'scan_read_view.dart';

typedef FolderChoice = ({String id, String name});

class ScanFlowScreen extends StatefulWidget {
  const ScanFlowScreen({
    super.key,
    required this.viewModel,
    required this.onSolve,
    required this.onAsk,
    required this.onMarked,
    required this.onPickFolder,
    required this.onSaved,
    this.folder,
  });

  final ScanFlowViewModel viewModel;
  final void Function(Scan scan, String text) onSolve;
  final void Function(Scan scan, String text) onAsk;
  final void Function(Scan scan, Marking marking) onMarked;
  final Future<FolderChoice?> Function() onPickFolder;
  final void Function(String folderId) onSaved;
  final FolderChoice? folder;

  @override
  State<ScanFlowScreen> createState() => _ScanFlowScreenState();
}

class _ScanFlowScreenState extends State<ScanFlowScreen> {
  ScanFlowViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.check.addListener(_onChecked);
    _viewModel.saveNotes.addListener(_onSaved);
    if (!_viewModel.hasManyPages && _viewModel.pages.isNotEmpty) {
      _viewModel.read.execute();
    }
  }

  @override
  void dispose() {
    _viewModel.check.removeListener(_onChecked);
    _viewModel.saveNotes.removeListener(_onSaved);
    _viewModel.dispose();
    super.dispose();
  }

  void _onChecked() {
    final scan = _viewModel.scan;
    if (_viewModel.check.result case Ok(:final value) when scan != null) {
      widget.onMarked(scan, value);
    }
  }

  NotesTarget? _target;

  void _onSaved() {
    if (_viewModel.saveNotes.isCompleted) {
      if (_target case final target?) widget.onSaved(target.folderId);
    }
  }

  void _save(NotesTarget target) {
    _target = target;
    _viewModel.saveNotes.execute(target);
  }

  Future<void> _retake() async {
    final source = await ScanSourceSheet.show(context, _viewModel.mode);
    if (source == null) return;
    await _viewModel.addPages.execute(source);
    if (!_viewModel.hasManyPages && _viewModel.pages.isNotEmpty) {
      await _viewModel.read.execute();
    }
  }

  void _addPage(PhotoSource source) => _viewModel.addPages.execute(source);

  void _retry() {
    final viewModel = _viewModel;
    if (viewModel.saveNotes.hasError) {
      if (_target case final target?) {
        _save(
          viewModel.failure == ScanFailure.proOnly
              ? (folderId: target.folderId, makeLesson: false)
              : target,
        );
      }
    } else if (viewModel.check.hasError) {
      viewModel.check.clearResult();
    } else {
      viewModel.read.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => StudyPage(
        title: _viewModel.mode.label,
        child: _FlowBody(
          viewModel: _viewModel,
          isMakingLesson: _target?.makeLesson ?? false,
          folder: widget.folder,
          onRetry: _retry,
          onRetake: _retake,
          onAddPage: _addPage,
          onPickFolder: widget.onPickFolder,
          onSave: _save,
          onSolve: widget.onSolve,
          onAsk: widget.onAsk,
        ),
      ),
    );
  }
}

class _FlowBody extends StatelessWidget {
  const _FlowBody({
    required this.viewModel,
    required this.isMakingLesson,
    required this.folder,
    required this.onRetry,
    required this.onRetake,
    required this.onAddPage,
    required this.onPickFolder,
    required this.onSave,
    required this.onSolve,
    required this.onAsk,
  });

  final ScanFlowViewModel viewModel;
  final bool isMakingLesson;
  final FolderChoice? folder;
  final VoidCallback onRetry;
  final VoidCallback onRetake;
  final ValueChanged<PhotoSource> onAddPage;
  final Future<FolderChoice?> Function() onPickFolder;
  final ValueChanged<NotesTarget> onSave;
  final void Function(Scan scan, String text) onSolve;
  final void Function(Scan scan, String text) onAsk;

  @override
  Widget build(BuildContext context) {
    final scan = viewModel.scan;
    final failure = viewModel.failure;
    final pages = viewModel.pages.length;
    if (viewModel.read.isRunning) {
      return ScanWaiting(
        title: pages > 1 ? 'Reading $pages pages…' : 'Reading your page…',
        text: 'This takes a few seconds.',
      );
    }
    if (viewModel.check.isRunning) {
      return const ScanWaiting(
        title: 'Marking your answer…',
        text: 'Using the board’s marking scheme.',
      );
    }
    if (viewModel.saveNotes.isRunning) {
      return ScanWaiting(
        title: isMakingLesson ? 'Making your lesson…' : 'Saving your notes…',
        text: 'It’ll be in your folder.',
      );
    }
    if (failure != null) {
      final problem = ScanProblem(
        failure: failure,
        onRetry: onRetry,
        onRetake: onRetake,
        onGoPro: () => Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed(Routes.paywall),
      );
      return switch (failure.limitFeature) {
        final feature? => OpensLimitSheet(feature: feature, child: problem),
        null => problem,
      };
    }
    if (scan == null) {
      return ScanPagesView(
        pages: viewModel.pages,
        isFull: viewModel.isFull,
        onAdd: onAddPage,
        onRemove: viewModel.removePage,
        onRead: viewModel.read.execute,
      );
    }
    if (scan.mode == ScanMode.notes) {
      return ScanNotesView(
        scan: scan,
        pages: pages,
        folder: folder,
        onPickFolder: onPickFolder,
        onSave: onSave,
      );
    }
    return ScanReadView(
      scan: scan,
      onSolve: (text) => onSolve(scan, text),
      onAsk: (text) => onAsk(scan, text),
      onMark: viewModel.check.execute,
    );
  }
}
