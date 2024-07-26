import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/models/device.dart';
import 'package:waste_free_home/routing/app_router.dart';
import 'package:waste_free_home/services/device_service.dart';
import 'package:waste_free_home/widgets/device_card.dart';

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

  Future<void> _showLinkWithDeviceDialog() async {
    final result = await context.router.push(QRScanRoute());
    if (result != null) {
      _linkDevice(result.toString());
    }
  }

  Future<void> _linkDevice(String uuid) async {
    try {
      await _deviceService.linkWithDevice(uuid);
        _refreshDevices();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: Text('Device linked successfully'),
            ),
          ),
        );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: DefaultTextStyle(
          style: TextStyle(color: Colors.white),
          child: Text('Error occurred while linking device'),
        ),
      ));
    }
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => context.router.push(DeviceDetailsRoute(id: snapshot.data![index].id)),
                      borderRadius: BorderRadius.circular(10),
                      child: DeviceCard(
                        device: snapshot.data![index],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLinkWithDeviceDialog,
        child: const Icon(Icons.link),
      ),
    );
  }
}
