import 'package:flutter/material.dart';

import '../../../domain/models/chat.dart';
import '../../../utils/result.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/screen_scale.dart';
import '../view_models/askme_view_model.dart';

class AskMeHistoryScreen extends StatefulWidget {
  const AskMeHistoryScreen({super.key, required this.viewModel});

  final AskMeViewModel viewModel;

  @override
  State<AskMeHistoryScreen> createState() => _AskMeHistoryScreenState();
}

class _AskMeHistoryScreenState extends State<AskMeHistoryScreen> {
  final _search = TextEditingController();

  AskMeViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.loadThreads.execute();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _open(ChatThread thread) async {
    await _viewModel.open.execute(thread);
    if (!mounted) return;
    if (_viewModel.open.result is Ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return AnnotatedRegion(
      value: context.palette.systemBars,
      child: Scaffold(
        backgroundColor: context.palette.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(padding - 8, 4, padding, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Back',
                      icon: const Icon(Icons.chevron_left_rounded, size: 28),
                      color: context.palette.text,
                    ),
                    Text(
                      'History',
                      style: AppTextStyles.display.copyWith(
                        fontSize: 24,
                        color: context.palette.text,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  style: AppTextStyles.input.copyWith(
                    color: context.palette.text,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search your questions',
                    hintStyle: AppTextStyles.label.copyWith(
                      color: context.palette.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: context.palette.textMuted,
                    ),
                    filled: true,
                    fillColor: context.palette.surfaceRaised,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) => _ThreadList(
                    threads: _filtered(_viewModel.threads),
                    isLoading: _viewModel.loadThreads.isRunning,
                    hasError: _viewModel.loadThreads.hasError,
                    onRetry: _viewModel.loadThreads.execute,
                    onOpen: _open,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ChatThread> _filtered(List<ChatThread> threads) {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return threads;
    return [
      for (final t in threads)
        if (t.title.toLowerCase().contains(query)) t,
    ];
  }
}

class _ThreadList extends StatelessWidget {
  const _ThreadList({
    required this.threads,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.onOpen,
  });

  final List<ChatThread> threads;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  final ValueChanged<ChatThread> onOpen;

  static final _modeIcons = <ChatMode, (IconData, Color Function(AppPalette))>{
    ChatMode.explain: (Icons.menu_book_rounded, (p) => p.tintLavender),
    ChatMode.solve: (Icons.extension_rounded, (p) => p.tintAmber),
    ChatMode.quiz: (Icons.task_alt_rounded, (p) => p.tintMint),
  };

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    if (threads.isEmpty) {
      return Center(
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.primary)
            : hasError
            ? TextButton(
                onPressed: onRetry,
                child: const Text('Couldn’t load your chats. Retry'),
              )
            : Text(
                'Your questions to Pebby will show up here.',
                style: AppTextStyles.label.copyWith(
                  color: context.palette.textMuted,
                ),
              ),
      );
    }
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recent = [
      for (final t in threads)
        if (t.updatedAt.isAfter(weekAgo)) t,
    ];
    final earlier = [
      for (final t in threads)
        if (!t.updatedAt.isAfter(weekAgo)) t,
    ];
    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
      children: [
        for (final (title, group) in [
          ('This week', recent),
          ('Earlier', earlier),
        ])
          if (group.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                title,
                style: AppTextStyles.subhead.copyWith(
                  fontSize: 14,
                  color: context.palette.text,
                ),
              ),
            ),
            for (final thread in group)
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => onOpen(thread),
                leading: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _modeIcons[thread.mode]!.$2(context.palette),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _modeIcons[thread.mode]!.$1,
                      size: 20,
                      color: context.palette.text,
                    ),
                  ),
                ),
                title: Text(
                  thread.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelStrong.copyWith(
                    color: context.palette.text,
                  ),
                ),
                subtitle: Text(
                  thread.mode.label,
                  style: AppTextStyles.caption.copyWith(
                    color: context.palette.textMuted,
                  ),
                ),
                trailing: Text(
                  _when(thread.updatedAt),
                  style: AppTextStyles.caption.copyWith(
                    color: context.palette.textMuted,
                  ),
                ),
              ),
          ],
      ],
    );
  }

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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

  static String _when(DateTime time) {
    final local = time.toLocal();
    final age = DateTime.now().difference(local);
    if (age.inHours < 24) {
      return age.inHours < 1 ? 'Now' : '${age.inHours}h';
    }
    if (age.inDays < 7) return _days[local.weekday - 1];
    return '${local.day} ${_months[local.month - 1]}';
  }
}
