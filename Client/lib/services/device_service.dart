import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:waste_free_home/utils/dio.dart';
import 'package:waste_free_home/models/device.dart';

class DeviceService {
  late final String address;
  late final String port;
  late final String endpoint;
  late final String baseUrl;
  late Dio _dio;

  DeviceService() {
    address = dotenv.env['server_address']!;
    port = dotenv.env['server_port']!;
    endpoint = dotenv.env['server_devices_endpoint']!;
    baseUrl = "http://$address:$port$endpoint";
    _dio = DioClient(baseUrl).dio;
  }

  Future<List<Device>> getMyDevices() async {
    final response = await _dio.get('/me');
    if (response.statusCode == 200) {
      final jsonData = response.data as List;
      return jsonData.map((json) => Device.fromJson(json)).toList();
    }
    print('Failed to load devices: ${response.statusCode}');
    throw Exception('Failed to load devices: ${response.statusCode}');
  }

  Future<Device> getDeviceById(String id) async {
    final response = await _dio.get('/$id');
    if (response.statusCode == 200) {
      return Device.fromJson(response.data);
    }
    print('Failed to load device: ${response.statusCode}');
    throw Exception('Failed to load device: ${response.statusCode}');
  }

  Future<Device> linkWithDevice(String deviceId) async {
    final response = await _dio.post('/link/$deviceId');
    if (response.statusCode == 200) {
      return Device.fromJson(response.data);
    }
    print('Failed to link with device: ${response.statusCode}');
    throw Exception('Failed to link with device: ${response.statusCode}');
  }
}
