import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/models/device.dart';
import 'package:waste_free_home/services/device_service.dart';
import 'package:waste_free_home/widgets/device_card.dart';

import 'package:flutter/material.dart';

@RoutePage()
class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
  final DeviceService _deviceService = DeviceService();
  late Future<List<Device>> _devicesFuture;

  @override
  void initState() {
    super.initState();
    _devicesFuture = _deviceService.getMyDevices();
  }

  Future<void> _refreshDevices() async {
    setState(() {
      _devicesFuture = _deviceService.getMyDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: _refreshDevices,
          child: FutureBuilder<List<Device>>(
            future: _devicesFuture,
            builder: (context, AsyncSnapshot<List<Device>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No devices found.'));
              } else {
                return GridView.builder(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return DeviceCard(
                      device: snapshot.data![index],
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}


