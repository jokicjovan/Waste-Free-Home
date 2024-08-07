import 'package:waste_free_home/models/record.dart';

class ThermoHumidMeterRecord extends Record{
  final double temperature;
  final double humidity;

  ThermoHumidMeterRecord({
    required super.timestamp,
    required this.temperature,
    required this.humidity,
  });

  factory ThermoHumidMeterRecord.fromJson(Map<String, dynamic> json) {
    return ThermoHumidMeterRecord(
      timestamp: DateTime.parse(json['timestamp']),
      temperature: json['temperature'],
      humidity: json['humidity'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'temperature': temperature,
      'humidity': humidity,
    };
  }
}
