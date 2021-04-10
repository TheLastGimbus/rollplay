import 'package:fluro/fluro.dart';

import 'pages/home_page.dart';
import 'pages/settings_page.dart';

final router = FluroRouter();

class Routes {
  static const home = '/';
  static const settings = '/settings';
}

void initRouter() {
  router.define(
    Routes.home,
    handler: Handler(handlerFunc: (ctx, params) => HomePage()),
  );
  router.define(
    Routes.settings,
    handler: Handler(handlerFunc: (ctx, params) => SettingsPage()),
    transitionType: TransitionType.inFromRight,
  );
}
