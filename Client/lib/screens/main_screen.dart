import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/routing/app_router.dart';
import 'package:waste_free_home/services/auth_service.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();

  void _logout(BuildContext context) async {
    await _authService.logout();
    context.router.replaceAll([const LoginRoute()]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: DefaultTextStyle(
          style: TextStyle(color: Colors.white),
          child: Text('Successfully logged out'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
          appBarBuilder: (_, index) => AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context),
                tooltip: "Log out",
              ),
            ],
          ),
          routes: const [MyDevicesRoute(), HubRoute()],
          bottomNavigationBuilder: (_, tabsRouter) {
            return BottomNavigationBar(
              currentIndex: tabsRouter.activeIndex,
              onTap: tabsRouter.setActiveIndex,
              items: const [
                BottomNavigationBarItem(
                    label: 'Devices', icon: Icon(Icons.device_thermostat)),
                BottomNavigationBarItem(
                    label: 'Hub', icon: Icon(Icons.device_hub)),
              ],
            );
          },
        );
  }
}
