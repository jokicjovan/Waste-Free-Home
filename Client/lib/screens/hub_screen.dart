import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/services/hub_service.dart';

@RoutePage()
class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => HubScreenState();
}

class HubScreenState extends State<HubScreen> {
  late Future<bool> _isOnlineFuture;
  final HubService _hubService = HubService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isOnlineFuture = _hubService.isOnline();
  }

  Future<void> _refreshHub() async {
    setState(() {
      _isOnlineFuture = _hubService.isOnline();
    });
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
  }

  Future<void> _updateCredentials() async {
    if (_formKey.currentState!.validate()) {
      try {
        final bool success = await _hubService.updateCredentials(
          _emailController.text,
          _passwordController.text,
        );
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credentials updated successfully')),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update credentials')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshHub,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: FutureBuilder<bool>(
                        future: _isOnlineFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            bool isOnline = snapshot.data!;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: isOnline ? Colors.green : Colors.red,
                                  size: 24.0,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isOnline ? 'Hub is Online' : 'Hub is Offline',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            );
                          } else {
                            return const Text('Unknown error');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.secondary),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              color: Theme.of(context).colorScheme.secondary,
                              child: const Text(
                                'Hub Credentials',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder()),
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
                                      border: OutlineInputBorder()),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                FilledButton(
                                  onPressed: _updateCredentials,
                                  style: FilledButton.styleFrom(
                                      minimumSize: const Size(160, 40)),
                                  child: const Text(
                                    'Update Credentials',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
