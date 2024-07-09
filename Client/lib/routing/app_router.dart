import 'package:auto_route/auto_route.dart';
import 'package:waste_free_home/routing/auth_guard.dart';
import 'package:waste_free_home/screens/devices_screen.dart';
import 'package:waste_free_home/screens/hub_screen.dart';
import 'package:waste_free_home/screens/login_screen.dart';
import 'package:waste_free_home/screens/main_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        RedirectRoute(path: '/', redirectTo: '/main'),
        AutoRoute(path: '/login', page: LoginRoute.page),
        AutoRoute(
            path: '/main',
            page: MainRoute.page,
            children: [
              AutoRoute(
                  path: 'devices', page: DevicesRoute.page, initial: true),
              AutoRoute(path: 'hub', page: HubRoute.page),
            ],
            initial: true,
            guards: [AuthGuard()]),
      ];
}
