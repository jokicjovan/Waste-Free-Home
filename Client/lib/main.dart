import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:waste_free_home/routing/app_router.dart';
import 'package:waste_free_home/utils/themes.dart';


void main() async {
  await dotenv.load(fileName: "assets/.env");
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
      theme: lightTheme,
      darkTheme: darkTheme,
      //Color.fromRGBO(101, 157, 82, 1.0)
      //Color.fromRGBO(47, 95, 73, 1.0)
      //Color.fromRGBO(21, 59, 48, 1.0)

      //Color.fromRGBO(248, 237, 194, 1.0)
    );
  }
}
