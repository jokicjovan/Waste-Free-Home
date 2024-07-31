// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [DeviceDetailsScreen]
class DeviceDetailsRoute extends PageRouteInfo<DeviceDetailsRouteArgs> {
  DeviceDetailsRoute({
    Key? key,
    required String id,
    List<PageRouteInfo>? children,
  }) : super(
          DeviceDetailsRoute.name,
          args: DeviceDetailsRouteArgs(
            key: key,
            id: id,
          ),
          initialChildren: children,
        );

  static const String name = 'DeviceDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeviceDetailsRouteArgs>();
      return DeviceDetailsScreen(
        key: args.key,
        id: args.id,
      );
    },
  );
}

class DeviceDetailsRouteArgs {
  const DeviceDetailsRouteArgs({
    this.key,
    required this.id,
  });

  final Key? key;

  final String id;

  @override
  String toString() {
    return 'DeviceDetailsRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [EditDeviceDetailsScreen]
class EditDeviceDetailsRoute extends PageRouteInfo<EditDeviceDetailsRouteArgs> {
  EditDeviceDetailsRoute({
    Key? key,
    required String id,
    List<PageRouteInfo>? children,
  }) : super(
          EditDeviceDetailsRoute.name,
          args: EditDeviceDetailsRouteArgs(
            key: key,
            id: id,
          ),
          rawPathParams: {'id': id},
          initialChildren: children,
        );

  static const String name = 'EditDeviceDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditDeviceDetailsRouteArgs>(
          orElse: () =>
              EditDeviceDetailsRouteArgs(id: pathParams.getString('id')));
      return EditDeviceDetailsScreen(
        key: args.key,
        id: args.id,
      );
    },
  );
}

class EditDeviceDetailsRouteArgs {
  const EditDeviceDetailsRouteArgs({
    this.key,
    required this.id,
  });

  final Key? key;

  final String id;

  @override
  String toString() {
    return 'EditDeviceDetailsRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [HubScreen]
class HubRoute extends PageRouteInfo<void> {
  const HubRoute({List<PageRouteInfo>? children})
      : super(
          HubRoute.name,
          initialChildren: children,
        );

  static const String name = 'HubRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HubScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainScreen();
    },
  );
}

/// generated route for
/// [MyDevicesScreen]
class MyDevicesRoute extends PageRouteInfo<void> {
  const MyDevicesRoute({List<PageRouteInfo>? children})
      : super(
          MyDevicesRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyDevicesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyDevicesScreen();
    },
  );
}

/// generated route for
/// [QRScanScreen]
class QRScanRoute extends PageRouteInfo<void> {
  const QRScanRoute({List<PageRouteInfo>? children})
      : super(
          QRScanRoute.name,
          initialChildren: children,
        );

  static const String name = 'QRScanRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const QRScanScreen();
    },
  );
}
