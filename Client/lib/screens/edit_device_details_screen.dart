import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/models/device.dart';
import 'package:waste_free_home/services/device_service.dart';

@RoutePage()
class EditDeviceDetailsScreen extends StatefulWidget {
  final String id;

  const EditDeviceDetailsScreen({super.key, @PathParam('id') required this.id});

  @override
  State<EditDeviceDetailsScreen> createState() =>
      _EditDeviceDetailsScreenState();
}

class _EditDeviceDetailsScreenState extends State<EditDeviceDetailsScreen> {
  final DeviceService _deviceService = DeviceService();
  final _formKey = GlobalKey<FormState>();
  late Future<Device?> _deviceFuture;
  String? _title;
  String? _description;

  @override
  void initState() {
    super.initState();
    _deviceFuture = _deviceService.getDeviceById(widget.id);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        await _deviceService.updateDevice(
          widget.id,
          title: _title!,
          description: _description!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device details updated successfully')),
        );
        context.router.popForced(true);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating device details: $error')),
        );
      }
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
              return Text(
                "Edit ${device.title}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: device.title,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _title = value;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: device.description,
                          decoration: const InputDecoration(labelText: 'Description'),
                          maxLines: 5,
                          style: const TextStyle(height: 1.2),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _description = value;
                          },
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _submitForm,
                          style: FilledButton.styleFrom(
                              minimumSize: const Size(160, 40)),
                          child: const Text(
                            'Update device',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
