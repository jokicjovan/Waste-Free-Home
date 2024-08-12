import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:waste_free_home/utils/dio.dart';

class DeviceAPService {
  late final String address;
  late final String endpoint;
  late final String baseUrl;
  late Dio _dio;

  DeviceAPService() {
    address = dotenv.env['device_ap_address'] ?? "192.168.4.1";
    baseUrl = "http://$address/API";
    _dio = DioClient(baseUrl).dio;
  }

  Future<bool> isOnline() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('Error checking if online: $e');
      return false;
    }
  }

  Future<void> updateNetworkCredentials(String ssid, String password) async {
    try {
      final response = await _dio.post(
        '/network-credentials',
        queryParameters: {
          'ssid': ssid,
          'password': password,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update credentials: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating credentials: $e');
    }
  }
}