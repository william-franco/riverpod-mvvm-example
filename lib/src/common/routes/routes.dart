import 'package:go_router/go_router.dart';
import 'package:riverpod_mvvm_example/src/features/settings/routes/setting_routes.dart';
import 'package:riverpod_mvvm_example/src/features/users/routes/user_routes.dart';

class Routes {
  static String get home => UserRoutes.users;

  GoRouter get routes => _routes;

  final GoRouter _routes = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: home,
    routes: [...UserRoutes().routes, ...SettingRoutes().routes],
  );
}
