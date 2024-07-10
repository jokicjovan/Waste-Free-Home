import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/routing/app_router.dart';
import 'package:waste_free_home/services/auth_service.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;

      final success = await _authService.login(email, password);
      if (success) {
        context.router.replaceAll([const MainRoute()]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: Text('Successfully logged in'),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.redAccent,
          content: DefaultTextStyle(
            style: TextStyle(color: Colors.white),
            child: Text('Incorrect email or password'),
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_full.png',
                width: 300,
                height: 300,
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 0, bottom: 0, left: 32, right: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          textStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
