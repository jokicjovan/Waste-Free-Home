import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
    address = dotenv.env['server_hostname']!;
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
    throw Exception('Failed to load devices: ${response.statusCode}');
  }

  Future<Device> getDeviceById(String id) async {
    final response = await _dio.get('/$id');
    if (response.statusCode == 200) {
      return Device.fromJson(response.data);
    }
    throw Exception('Failed to load device: ${response.statusCode}');
  }

  Future<Device> linkWithDevice(String id) async {
    final response = await _dio.post('/link/$id');
    if (response.statusCode == 200) {
      return Device.fromJson(response.data);
    }
    throw Exception('Failed to link with device: ${response.statusCode}');
  }

  Future<Device> updateDevice(String id,
      {required String title, required String description}) async {
    final response = await _dio.put('/$id',
        data: jsonEncode({"title": title, "description": description}));
    if (response.statusCode == 200) {
      return Device.fromJson(response.data);
    }
    throw Exception('Failed to update device: ${response.statusCode}');
  }

  Future<ImageProvider> getDeviceThumbnail(String id) async {
    final response = await _dio.get(
      '/$id/thumbnail',
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.statusCode == 200) {
      return MemoryImage(Uint8List.fromList(response.data));
    }
    throw Exception('Failed to load thumbnail: ${response.statusCode}');
  }
}
