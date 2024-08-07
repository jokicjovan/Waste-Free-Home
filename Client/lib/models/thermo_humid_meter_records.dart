import 'package:waste_free_home/models/record.dart';

class ThermoHumidMeterTemperatureRecord extends Record{
  final double temperature;

  ThermoHumidMeterTemperatureRecord({
    required super.timestamp,
    required this.temperature,
  });

  factory ThermoHumidMeterTemperatureRecord.fromJson(Map<String, dynamic> json) {
    return ThermoHumidMeterTemperatureRecord(
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
