import 'package:flutter/widgets.dart';

String? resetLinkToken(String? routeName) {
  final uri = Uri.tryParse(routeName ?? '');
  final token = uri?.queryParameters['c'] ?? '';
  if (uri == null || token.isEmpty) return null;
  final isWebLink =
      uri.path == '/reset-password' &&
      (uri.host.isEmpty || uri.host == 'academe.cc');
  final isAppLink =
      (uri.scheme == 'academe' && uri.host == 'reset') ||
      (!uri.hasScheme && uri.path == '/');
  return isWebLink || isAppLink ? token : null;
}

class DeepLinkFilter with WidgetsBindingObserver {
  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async => resetLinkToken(routeInformation.uri.toString()) == null;
}
