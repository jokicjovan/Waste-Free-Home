import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/services/device_ap_service.dart';

@RoutePage()
class DeviceAPScreen extends StatefulWidget {
  const DeviceAPScreen({super.key});

  @override
  State<DeviceAPScreen> createState() => DeviceAPScreenState();
}

class DeviceAPScreenState extends State<DeviceAPScreen> {
  late Future<bool> _isOnlineFuture;
  final DeviceAPService _deviceAPService = DeviceAPService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isOnlineFuture = _checkDeviceAPStatus();
  }

  Future<bool> _checkDeviceAPStatus() async {
    try {
      return await Future.any([
        _deviceAPService.isOnline(),
        Future.delayed(const Duration(seconds: 10),
                () => throw TimeoutException('Device AP status check timed out'))
      ]);
    } catch (e) {
      print('Error checking device AP status: $e');
      return false;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isOnlineFuture = _checkDeviceAPStatus();
    });
  }

  Future<void> _updateCredentials() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _deviceAPService.updateNetworkCredentials(
          _ssidController.text,
          _passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Network credentials updated successfully')),
        );
        _clearForm();
        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _ssidController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<bool>(
          future: _isOnlineFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError || !snapshot.hasData || (snapshot.hasData && !snapshot.data!)) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8, // Adjust as needed
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Colors.red,
                                size: 24.0,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                snapshot.hasError
                                    ? 'Error: ${snapshot.error}'
                                    : 'Device AP is Offline',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            'You should be connected to device AP(WIFI) to update network credentials.',
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            'Reset Device, Connect to AP and try again!',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            bool isOnline = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8, // Adjust as needed
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isOnline)
                          const Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 24.0,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Device AP is Online',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20), // Add some spacing
                            ],
                          ),
                        if (isOnline)
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
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    color: Theme.of(context).colorScheme.secondary,
                                    child: const Text(
                                      'Network Credentials',
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
                                        controller: _ssidController,
                                        decoration: const InputDecoration(
                                            labelText: 'SSID',
                                            border: OutlineInputBorder()),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your network SSID';
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
                                            return 'Please enter your network password';
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
                                          'Update Network Credentials',
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
