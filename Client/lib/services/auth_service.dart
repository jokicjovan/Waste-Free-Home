import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_free_home/utils/dio.dart';

class AuthService {
  late final String address;
  late final String port;
  late final String endpoint;
  late final String baseUrl;
  late Dio _dio;

  AuthService() {
    address = dotenv.env['server_address']!;
    port = dotenv.env['server_port']!;
    endpoint = dotenv.env['server_auth_endpoint']!;
    baseUrl = "http://$address:$port$endpoint";
    _dio = DioClient(baseUrl).dio;
  }

  Future<void> login(String email, String password) async {
    final response = await _dio.post(
      '/token',
      data: {
        'username': email,
        'password': password,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
      ),
    );

    if (response.statusCode != 200) throw Exception("Failed to login");

    final token = response.data['access_token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<void> checkTokenValidity() async {
    final token = await getToken();
    if (token == null) throw Exception("No token found");

    final response = await _dio.get('/validate_token');

    if (response.statusCode != 200) throw Exception("Failed to validate token");
  }
}
