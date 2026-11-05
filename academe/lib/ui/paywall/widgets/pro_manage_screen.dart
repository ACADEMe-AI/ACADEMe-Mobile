import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/pro.dart';
import '../../../routing/routes.dart';
import '../../../utils/dates.dart';
import '../../../utils/result.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/keycap_surface.dart';
import '../../core/ui/screen_scale.dart';
import '../view_models/pro_view_model.dart';

part 'pro_manage_hero.dart';
part 'pro_manage_meters.dart';
part 'pro_manage_footer.dart';

class ProManageScreen extends StatefulWidget {
  const ProManageScreen({super.key, required this.viewModel});

  final ProViewModel viewModel;

  @override
  State<ProManageScreen> createState() => _ProManageScreenState();
}

class _ProManageScreenState extends State<ProManageScreen> {
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    widget.viewModel.load.execute();
    widget.viewModel.load.addListener(_onLoad);
  }

  @override
  void dispose() {
    widget.viewModel.load.removeListener(_onLoad);
    widget.viewModel.dispose();
    super.dispose();
  }

  void _onLoad() {
    if (widget.viewModel.load.result case Ok()) {
      _lastRefresh = DateTime.now();
    }
  }

  Future<void> _refresh() async {
    final now = DateTime.now();
    if (_lastRefresh != null &&
        now.difference(_lastRefresh!) < const Duration(seconds: 3)) {
      return;
    }
    await widget.viewModel.load.execute();
  }

  Future<void> _goPro() async {
    final bought = await Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed<bool>(Routes.paywall);
    if (bought == true && mounted) {
      await widget.viewModel.load.execute();
    }
  }

  Future<void> _restore() async {
    await widget.viewModel.restore.execute();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final padding = ScreenScale.of(context).pagePadding;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final plan = viewModel.plan;
        final isPro = viewModel.isPro;
        return Scaffold(
          backgroundColor: context.palette.surface,
          appBar: AppBar(
            title: Text(isPro ? 'ACADEMe Pro' : 'Plan & limits'),
            backgroundColor: context.palette.surface,
            foregroundColor: context.palette.text,
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(padding, 8, padding, 16),
                    children: [
                      _PlanHero(isPro: isPro, plan: plan),
                      const SizedBox(height: 12),
                      _DailyLimitsCard(plan: plan, isPro: isPro),
                      if (plan.weekLimit > 0) ...[
                        const SizedBox(height: 12),
                        _WeeklyLimitCard(plan: plan),
                      ],
                    ],
                  ),
                ),
              ),
              _ManageFooter(
                isPro: isPro,
                notice: viewModel.notice,
                onGoPro: _goPro,
                onManage: () => launchUrl(
                  Uri.parse(viewModel.manageUrl),
                  mode: LaunchMode.externalApplication,
                ),
                onRestore: _restore,
              ),
            ],
          ),
        );
      },
    );
  }
}
