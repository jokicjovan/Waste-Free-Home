import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/models/device.dart';
import 'package:waste_free_home/services/device_service.dart';
import 'package:waste_free_home/utils/helper_methods.dart';
import 'package:waste_free_home/widgets/thermometer_recorded_data.dart';
import 'package:waste_free_home/widgets/waste_sorter_recorded_data.dart';

@RoutePage()
class DeviceDetailsScreen extends StatefulWidget {
  final String id;

  const DeviceDetailsScreen({super.key, @PathParam('id') required this.id});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  final DeviceService _deviceService = DeviceService();
  late Future<Device?> _deviceFuture;

  @override
  void initState() {
    super.initState();
    _deviceFuture = _deviceService.getDeviceById(widget.id);
  }

  Widget _buildDeviceWidget(
      {required DeviceType type, required String deviceId}) {
    switch (type) {
      case DeviceType.WASTE_SORTER:
        return WasteSorterRecordedData(deviceId: deviceId);
      case DeviceType.THERMOMETER:
        return ThermometerRecordedData(deviceId: deviceId);
      default:
        return const Center(child: Text('No data available for this device type.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Device?>(
          future: _deviceFuture,
          builder:
              (BuildContext context, AsyncSnapshot<Device?> deviceSnapshot) {
            if (deviceSnapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (deviceSnapshot.hasError) {
              return Text('Error: ${deviceSnapshot.error}');
            } else if (!deviceSnapshot.hasData || deviceSnapshot.data == null) {
              return const Text('No device found');
            } else {
              final device = deviceSnapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatDeviceType(device.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: FutureBuilder<Device?>(
        future: _deviceFuture,
        builder: (BuildContext context, AsyncSnapshot<Device?> deviceSnapshot) {
          if (deviceSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (deviceSnapshot.hasError) {
            return Center(
              child: Text('Error: ${deviceSnapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          } else if (!deviceSnapshot.hasData || deviceSnapshot.data == null) {
            return const Center(
              child:
                  Text('No device found', style: TextStyle(color: Colors.grey)),
            );
          } else {
            final device = deviceSnapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: device.imageUrl != null
                        ? Image.network(
                            device.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          )
                        : Image.asset(
                            getDefaultDeviceImageUrl(device.type),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: const Column(
                                  children: [
                                    Text(
                                      'Description',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  device.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _buildDeviceWidget(
                              type: device.type,
                              deviceId: widget.id),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
