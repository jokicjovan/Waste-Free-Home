class Device {
  final String id;
  final String title;
  final String description;
  final String type;
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
      type: json['type'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
