import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/routing/auth_guard.dart';
import 'package:waste_free_home/screens/QR_scan_screen.dart';
import 'package:waste_free_home/screens/device_ap_screen.dart';
import 'package:waste_free_home/screens/device_details_screen.dart';
import 'package:waste_free_home/screens/edit_device_details_screen.dart';
import 'package:waste_free_home/screens/my_devices_screen.dart';
import 'package:waste_free_home/screens/hub_screen.dart';
import 'package:waste_free_home/screens/login_screen.dart';
import 'package:waste_free_home/screens/main_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/login', page: LoginRoute.page),
        AutoRoute(path: '/', page: MainRoute.page, initial: true, guards: [
          AuthGuard()
        ], children: [
          AutoRoute(path: 'devices', page: MyDevicesRoute.page, initial: true),
          AutoRoute(path: 'hub', page: HubRoute.page),
          AutoRoute(path: 'device_ap', page: DeviceAPRoute.page),
        ]),
        AutoRoute(
            path: '/devices/:id',
            page: DeviceDetailsRoute.page,
            guards: [AuthGuard()]),
        AutoRoute(
            path: '/devices/:id/edit',
            page: EditDeviceDetailsRoute.page,
            guards: [AuthGuard()]),
        AutoRoute(
            path: '/devices/link/qr-scan',
            page: QRScanRoute.page,
            guards: [AuthGuard()]),
      ];
}
