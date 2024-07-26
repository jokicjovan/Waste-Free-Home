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
    final response = await _dio.get('/health');
    if (response.statusCode == 200) {
      return true;
    }
    print('Failed to retrieve hub status: ${response.statusCode}');
    throw Exception('Failed to retrieve hub status: ${response.statusCode}');
  }

  Future<bool> updateCredentials(String email, String password) async {
    final response = await _dio.put(
      '/update-credentials',
      data: {
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      return true;
    }
    print('Failed to update credentials: ${response.statusCode}');
    throw Exception('Failed to update credentials:  ${response.statusCode}');
  }
}
