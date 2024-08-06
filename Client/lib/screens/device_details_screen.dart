import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/models/device.dart';
import 'package:waste_free_home/routing/app_router.dart';
import 'package:waste_free_home/services/device_service.dart';
import 'package:waste_free_home/utils/helper_methods.dart';
import 'package:waste_free_home/widgets/thermo_humid_meter_records_data.dart';
import 'package:waste_free_home/widgets/waste_sorter_records_data.dart';

@RoutePage()
class DeviceDetailsScreen extends StatefulWidget {
  final String id;

  const DeviceDetailsScreen({super.key, required this.id});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  final DeviceService _deviceService = DeviceService();
  late Future<Device?> _deviceFuture;

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  Future<void> _loadDevice() async {
    setState(() {
      _deviceFuture = _deviceService.getDeviceById(widget.id);
    });
  }

  void _showFullScreenImage(BuildContext context, ImageProvider image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              child: Image(image: image),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceWidget(
      {required DeviceType type, required String deviceId}) {
    switch (type) {
      case DeviceType.WASTE_SORTER:
        return WasteSorterRecordsData(deviceId: deviceId);
      case DeviceType.THERMO_HUMID_METER:
        return ThermoHumidMeterRecordsData(deviceId: deviceId);
      default:
        return const Center(child: Text('No data available for this device type.'));
    }
  }

  Future<void> _editDetails(BuildContext context) async {
    final result = await context.router.push(EditDeviceDetailsRoute(id: widget.id));
    if (result == true) {
      _loadDevice();
    }
  }

  Future<void> _onRefresh() async {
    await _loadDevice();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editDetails(context),
            tooltip: "Edit details",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<Device?>(
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
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final imageProvider = await _deviceService.getDeviceThumbnail(device.id);
                                  _showFullScreenImage(context, imageProvider);
                                },
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                  child: FutureBuilder<ImageProvider>(
                                    future: _deviceService.getDeviceThumbnail(device.id),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const SizedBox(
                                          width: double.infinity,
                                          height: 200,
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Image.asset(
                                          getDefaultDeviceImageUrl(device.type),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                        );
                                      } else if (snapshot.hasData) {
                                        return Image(
                                          image: snapshot.data!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                        );
                                      } else {
                                        return Image.asset(
                                          getDefaultDeviceImageUrl(device.type),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5), // Background color with some transparency
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 8,
                                          backgroundColor: device.isOnline ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          device.isOnline ? 'Online' : 'Offline',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                _buildDeviceWidget(
                                    type: device.type, deviceId: widget.id),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
