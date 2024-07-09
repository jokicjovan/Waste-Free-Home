import 'package:flutter/material.dart';
import 'package:waste_free_home/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(),
      title: 'Waste Free Home',
      debugShowCheckedModeBanner: false,
      // navigatorKey: navigatorKey,
      // initialRoute: isLoggedIn ? '/home' : '/login',
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/home': (context) => const MainScreen(),
      // },
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color.fromRGBO(248, 237, 194, 1.0),
        colorScheme: const ColorScheme(
          primary: Color.fromRGBO(101, 157, 82, 1.0),
          onPrimary: Colors.white,
          secondary: Color.fromRGBO(47, 95, 73, 1.0),
          onSecondary: Colors.white,
          surface: Color.fromRGBO(47, 95, 73, 1.0),
          onSurface: Color.fromRGBO(21, 59, 48, 1.0),
          error: Colors.red,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
    );
  }
}
