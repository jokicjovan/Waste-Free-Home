import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:waste_free_home/utils/dio.dart';

class HubService {
  late final String address;
  late final String port;
  late final String baseUrl;
  late Dio _dio;

  HubService() {
    address = dotenv.env['hub_address']!;
    port = dotenv.env['hub_port']!;
    baseUrl = "http://$address:$port/API";
    _dio = DioClient(baseUrl).dio;
  }

  Future<bool> isOnline() async {
    try {
      final response = await _dio.get('/health');
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error retrieving hub status: $e');
    }
    return false;
  }

  Future<bool> updateCredentials(String email, String password) async {
    try {
      final response = await _dio.put(
        '/update-credentials',
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update credentials: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating credentials: $e');
    }
    return false;
  }
}
