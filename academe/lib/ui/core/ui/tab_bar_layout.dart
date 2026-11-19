import 'package:flutter/widgets.dart';

import '../../shell/widgets/soft_update_banner.dart';

abstract final class TabBarLayout {
  static const barHeight = 64.0;
  static const depth = 4.0;
  static const outerBottomPadding = 12.0;
  static const listTrailingPadding = 24.0;

  static double scrollBottomPadding(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom +
      barHeight +
      depth +
      outerBottomPadding +
      SoftUpdateInset.of(context);
}
