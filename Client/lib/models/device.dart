enum DeviceType {
  THERMOMETER,
  WASTE_SORTER,
}

class Device {
  final String id;
  final String title;
  final String description;
  final DeviceType type;
  final String? imageUrl;

  Device({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.imageUrl,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: DeviceType.values.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == (json['type'] as String).toUpperCase(),
        orElse: () => throw ArgumentError('Unknown device type: ${json['type']}'),
      ),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
    };
  }
}
