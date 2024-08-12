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
      appBarBuilder: (context, index) {
        final tabsRouter = AutoTabsRouter.of(context);
        final currentIndex = tabsRouter.activeIndex;

        return AppBar(
          title: Text(currentIndex == 0 ? 'My devices' : currentIndex == 1 ? 'Hub' : 'Device AP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
              tooltip: "Log out",
            ),
          ],
        );
      },
      routes: const [MyDevicesRoute(), HubRoute(), DeviceAPRoute()],
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          items: const [
            BottomNavigationBarItem(
                label: 'Devices', icon: Icon(Icons.device_thermostat)),
            BottomNavigationBarItem(
                label: 'Hub', icon: Icon(Icons.device_hub)),
            BottomNavigationBarItem(
                label: 'Device AP', icon: Icon(Icons.wifi)),
          ],
        );
      },
    );
  }
}
