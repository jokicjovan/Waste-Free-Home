// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    DeviceDetailsRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<DeviceDetailsRouteArgs>(
          orElse: () => DeviceDetailsRouteArgs(id: pathParams.getString('id')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DeviceDetailsScreen(
          key: args.key,
          id: args.id,
        ),
      );
    },
    DevicesRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DevicesScreen(),
      );
    },
    HubRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HubScreen(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    MainRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MainScreen(),
      );
    },
  };
}

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
          rawPathParams: {'id': id},
          initialChildren: children,
        );

  static const String name = 'DeviceDetailsRoute';

  static const PageInfo<DeviceDetailsRouteArgs> page =
      PageInfo<DeviceDetailsRouteArgs>(name);
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
/// [DevicesScreen]
class DevicesRoute extends PageRouteInfo<void> {
  const DevicesRoute({List<PageRouteInfo>? children})
      : super(
          DevicesRoute.name,
          initialChildren: children,
        );

  static const String name = 'DevicesRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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

  static const PageInfo<void> page = PageInfo<void>(name);
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

  static const PageInfo<void> page = PageInfo<void>(name);
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

  static const PageInfo<void> page = PageInfo<void>(name);
}
