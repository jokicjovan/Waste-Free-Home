import 'package:dio/dio.dart';
import 'package:waste_free_home/utils/auth_interceptor.dart';

class DioClient {
  final Dio _dio;

  DioClient(String baseUrl) : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
  )) {
    _dio.interceptors.add(AuthInterceptor());
  }

  Dio get dio => _dio;
}