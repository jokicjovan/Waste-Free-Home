import 'package:flutter/material.dart';
import 'package:waste_free_home/models/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  String _getDefaultImage(String type) {
    switch (type) {
      case 'WASTE_SORTER':
        return 'assets/images/waste_sorter_default_opaque.png';
      case 'THERMOMETER':
        return 'assets/images/thermometer_default_opaque.png';
      default:
        return 'assets/images/recycling.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: (){},
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1), // 1 px border
            borderRadius:
                BorderRadius.circular(10), // Match the border radius of the Card
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: device.imageUrl != null
                    ? Image.network(
                        device.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 140,
                      )
                    : Image.asset(
                        _getDefaultImage(device.type),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 140,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
