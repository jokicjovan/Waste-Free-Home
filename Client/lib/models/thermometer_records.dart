import 'package:waste_free_home/models/record.dart';

class ThermometerTemperatureRecord extends Record{
  final double temperature;

  ThermometerTemperatureRecord({
    required DateTime timestamp,
    required this.temperature,
  }) : super(timestamp: timestamp);

  factory ThermometerTemperatureRecord.fromJson(Map<String, dynamic> json) {
    return ThermometerTemperatureRecord(
      timestamp: DateTime.parse(json['timestamp']),
      temperature: json['temperature'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'temperature': temperature,
    };
  }
}
