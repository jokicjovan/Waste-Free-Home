import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async {
    return handler.next(response);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
    }
    return handler.next(err);
  }
}
