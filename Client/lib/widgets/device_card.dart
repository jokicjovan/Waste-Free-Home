import 'package:flutter/material.dart';
import 'package:waste_free_home/models/device.dart';
import 'package:waste_free_home/utils/helper_methods.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.black, width: 1))
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: device.imageUrl != null
                    ? Image.network(
                        device.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 120,
                      )
                    : Image.asset(
                        getDefaultDeviceImageUrl(device.type),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 120,
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formatDeviceType(device.type),
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    device.description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
