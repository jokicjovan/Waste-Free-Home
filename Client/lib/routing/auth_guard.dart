import 'package:auto_route/auto_route.dart';
import 'package:waste_free_home/routing/app_router.dart';
import 'package:waste_free_home/services/auth_service.dart';


class AuthGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    final AuthService authService = AuthService();
    final isLoggedIn = await authService.isTokenValid();
    if (isLoggedIn) {
      resolver.next(true);
    } else {
      router.replaceAll([const LoginRoute()]);
    }
  }
}