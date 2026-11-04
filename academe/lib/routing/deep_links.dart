import 'package:flutter/widgets.dart';

const _linkHosts = {'api.academe.cc', 'academe.cc'};

String? resetLinkToken(String? routeName) {
  final uri = Uri.tryParse(routeName ?? '');
  final token = uri?.queryParameters['c'] ?? '';
  if (uri == null || token.isEmpty || uri.path != '/reset-password') {
    return null;
  }
  final isRoute = !uri.hasScheme && uri.host.isEmpty;
  final isWebLink = uri.scheme == 'https' && _linkHosts.contains(uri.host);
  return isRoute || isWebLink ? token : null;
}

class DeepLinkFilter with WidgetsBindingObserver {
  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async => resetLinkToken(routeInformation.uri.toString()) == null;
}
