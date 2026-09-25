import 'package:flutter/widgets.dart';

import '../view_models/notification_primer_view_model.dart';
import 'notification_primer_sheet.dart';

class NotificationPrimerHost extends StatefulWidget {
  const NotificationPrimerHost({
    super.key,
    required this.viewModel,
    required this.child,
  });

  final NotificationPrimerViewModel viewModel;
  final Widget child;

  @override
  State<NotificationPrimerHost> createState() => _NotificationPrimerHostState();
}

class _NotificationPrimerHostState extends State<NotificationPrimerHost> {
  late final AppLifecycleListener _lifecycle;
  var _isShowing = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: widget.viewModel.resumed);
    widget.viewModel.addListener(_showPrimer);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPrimer());
  }

  Future<void> _showPrimer() async {
    if (!mounted || _isShowing || !widget.viewModel.wantsPrimer) return;
    _isShowing = true;
    final allow = await NotificationPrimerSheet.show(context);
    _isShowing = false;
    await widget.viewModel.answer(allow: allow ?? false);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_showPrimer);
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
