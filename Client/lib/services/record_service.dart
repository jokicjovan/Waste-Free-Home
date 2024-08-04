import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:waste_free_home/models/thermometer_records.dart';
import 'package:waste_free_home/models/waste_sorter_records.dart';
import 'package:waste_free_home/utils/dio.dart';

class RecordService {
  late final String address;
  late final String port;
  late final String endpoint;
  late final String baseUrl;
  late Dio _dio;

  RecordService() {
    address = dotenv.env['server_hostname']!;
    port = dotenv.env['server_port']!;
    endpoint = dotenv.env['server_records_endpoint']!;
    baseUrl = "http://$address:$port$endpoint";
    _dio = DioClient(baseUrl).dio;
  }

  Future<Map<String, List<dynamic>>> fetchRecords(String deviceId,
      {DateTime? startDate, DateTime? endDate}) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }

    final response = await _dio.get(
      '/$deviceId',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final data = response.data;

      final recycleRecords = (data['waste_sorter_recycle_record'] as List?)
          ?.map((record) => WasteSorterRecycleRecord.fromJson(record))
          .toList();
      final levelRecords = (data['waste_sorter_level_record'] as List?)
          ?.map((record) => WasteSorterLevelRecord.fromJson(record))
          .toList();
      final temperatureRecords = (data['thermometer_record'] as List?)
          ?.map((record) => ThermometerTemperatureRecord.fromJson(record))
          .toList();

      if (recycleRecords != null && levelRecords != null) {
        return {
          'recycleRecords': recycleRecords,
          'levelRecords': levelRecords,
        };
      } else if (temperatureRecords != null) {
        return {
          'temperatureRecords': temperatureRecords,
        };
      } else {
        throw Exception('No valid records found');
      }
    } else {
      throw Exception('Failed to load records');
    }
  }

  String getWsConnection(String deviceId){
    return "ws://$address:$port$endpoint/$deviceId";
  }
}
