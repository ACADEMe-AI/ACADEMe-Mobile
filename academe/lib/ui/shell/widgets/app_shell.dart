import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/repositories/photo_repository.dart';
import '../../../domain/models/chat.dart';
import '../../../domain/models/scan.dart';
import '../../../utils/result.dart';
import '../../askme/view_models/askme_view_model.dart';
import '../../askme/widgets/askme_history_screen.dart';
import '../../askme/widgets/askme_screen.dart';
import '../../askme/widgets/attach_sheet.dart';
import '../../core/themes/app_theme.dart';
import '../../home/view_models/home_view_model.dart';
import '../../home/view_models/today_view_model.dart';
import '../../home/widgets/home_screen.dart';
import '../../me/view_models/me_view_model.dart';
import '../../me/widgets/help_screen.dart';
import '../../me/widgets/me_screen.dart';
import '../../me/widgets/privacy_screen.dart';
import '../../paywall/view_models/pro_view_model.dart';
import '../../paywall/widgets/pro_card.dart';
import '../../scan/scan_factory.dart';
import '../../scan/view_models/scan_view_model.dart';
import '../../scan/widgets/scan_flow_screen.dart';
import '../../scan/widgets/scan_screen.dart';
import '../../study/study_factory.dart';
import '../../study/view_models/folders_view_model.dart';
import '../../study/view_models/study_view_model.dart';
import '../../study/widgets/study_screen.dart';
import 'app_nav_bar.dart';
import 'me_navigation.dart';
import 'scan_navigation.dart';
import 'study_navigation.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.viewModel,
    required this.askMe,
    required this.me,
    required this.study,
    required this.folders,
    required this.today,
    required this.factory,
    required this.scan,
    required this.scans,
    this.pro,
    this.onRemindersWanted,
    this.opensSetup = false,
    this.onLoggedOut,
  });

  final HomeViewModel viewModel;
  final AskMeViewModel askMe;
  final MeViewModel me;
  final StudyViewModel study;
  final FoldersViewModel folders;
  final TodayViewModel today;
  final StudyFactory factory;
  final ScanViewModel scan;
  final ScanFactory scans;
  final ProViewModel? pro;
  final VoidCallback? onRemindersWanted;
  final bool opensSetup;
  final VoidCallback? onLoggedOut;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with StudyNavigation, MeNavigation, ScanNavigation {
  static const _askMeTab = 1;

  int _tab = 0;
  int _returnTab = 0;
  final _ask = TextEditingController();
  final _askFocus = FocusNode();

  HomeViewModel get _viewModel => widget.viewModel;
  AskMeViewModel get _askMe => widget.askMe;
  MeViewModel get _me => widget.me;
  bool get _isAsking => _tab == _askMeTab;

  @override
  void initState() {
    super.initState();
    _me.logOut.addListener(_onLeft);
    _me.deleteAccount.addListener(_onLeft);
    widget.today.load.execute();
  }

  @override
  void dispose() {
    _me.logOut.removeListener(_onLeft);
    _me.deleteAccount.removeListener(_onLeft);
    _viewModel.dispose();
    _me.dispose();
    widget.study.dispose();
    widget.folders.dispose();
    widget.today.dispose();
    widget.scan.dispose();
    _askMe.dispose();
    _ask.dispose();
    _askFocus.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _tab) return;
    if (index == _askMeTab) _returnTab = _tab;
    if (_isAsking) _askFocus.unfocus();
    if (index == 0) widget.today.load.execute();
    setState(() => _tab = index);
  }

  void _openAskMe() {
    _select(_askMeTab);
    _askFocus.requestFocus();
  }

  void _send() {
    final text = _ask.text.trim();
    if (text.isEmpty || _askMe.isThinking) return;
    _ask.clear();
    _askMe.send.execute(text);
  }

  void _soon(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _attach() {
    _askFocus.unfocus();
    AttachSheet.show(
      context,
      onPick: (option) => switch (option) {
        AttachSheet.camera => startScan(
          ScanMode.ask,
          source: PhotoSource.camera,
        ),
        AttachSheet.photos => startScan(
          ScanMode.ask,
          source: PhotoSource.gallery,
        ),
        _ => _soon('$option is coming soon.'),
      },
    );
  }

  @override
  void scanNotes(FolderChoice folder) =>
      startScan(ScanMode.notes, folder: folder);

  @override
  Future<void> askPebby(
    ChatMode mode,
    String text, {
    ValueChanged<String>? onThread,
  }) async {
    Navigator.of(context).popUntil((r) => r.isFirst);
    _askMe
      ..newChat()
      ..setMode(mode);
    _select(_askMeTab);
    await _askMe.send.execute(text);
    final threadId = _askMe.threadId;
    if (threadId != null) onThread?.call(threadId);
  }

  @override
  void openThread(ChatThread thread) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    _askMe.open.execute(thread);
    _select(_askMeTab);
  }

  void _history() {
    _askFocus.unfocus();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AskMeHistoryScreen(viewModel: _askMe),
      ),
    );
  }

  void _onLeft() {
    if (_me.deleteAccount.result case Ok(:final value)) {
      _soon(
        'Your account will be deleted on ${_date(value)}. '
        'Log in before then to keep it.',
      );
      widget.onLoggedOut?.call();
    } else if (_me.logOut.isCompleted) {
      widget.onLoggedOut?.call();
    }
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _date(DateTime time) {
    final local = time.toLocal();
    return '${local.day} ${_months[local.month - 1]} ${local.year}';
  }

  @override
  void showMessage(String message) => _soon(message);

  @override
  void askAbout(String question) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    _ask.text = question;
    _openAskMe();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.palette.systemBars,
      child: PopScope(
        canPop: _tab == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _select(_isAsking ? _returnTab : 0);
        },
        child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: context.palette.surface,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _tab,
              children: [
                HomeScreen(
                  viewModel: _viewModel,
                  opensSetup: widget.opensSetup,
                  onAsk: _openAskMe,
                  today: widget.today,
                  onOpenTask: studyActions.openTask,
                  onFlashcards: () => openReview(null),
                  onSolve: () => startScan(ScanMode.solve),
                  onCheck: () => startScan(ScanMode.check),
                ),
                ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) => AskMeScreen(
                    viewModel: _askMe,
                    name: _viewModel.account?.firstName ?? 'there',
                    syllabus: _viewModel.syllabusLabel,
                    onBack: () => _select(_returnTab),
                    onHistory: _history,
                    onMakeFlashcards: () =>
                        _soon('Flashcards are coming soon.'),
                  ),
                ),
                ScanScreen(
                  viewModel: widget.scan,
                  onStart: startScan,
                  onOpen: openScan,
                ),
                StudyScreen(
                  viewModel: widget.study,
                  folders: widget.folders,
                  actions: studyActions,
                  onNewFolder: newFolder,
                ),
                MeScreen(
                  viewModel: _me,
                  onClassAndBoard: openClassAndBoard,
                  onLanguage: openLanguage,
                  onAppearance: openAppearance,
                  onNotifications: openNotifications,
                  onAccount: openAccount,
                  onHelp: () => pushMe<void>(const HelpScreen()),
                  onPrivacy: () => pushMe<void>(const PrivacyScreen()),
                  onLogOut: confirmLogOut,
                  pro: switch (widget.pro) {
                    final pro? => ProCard(viewModel: pro),
                    null => null,
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: ListenableBuilder(
            listenable: Listenable.merge([_ask, _askMe]),
            builder: (context, _) => AppNavBar(
              selected: _tab,
              onSelect: _select,
              isAsking: _isAsking,
              askController: _ask,
              askFocus: _askFocus,
              canSend: _ask.text.trim().isNotEmpty && !_askMe.isThinking,
              onSend: _send,
              onAttach: _attach,
            ),
          ),
        ),
      ),
    );
  }
}
