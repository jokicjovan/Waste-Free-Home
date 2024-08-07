import 'package:bonsoir/bonsoir.dart';
import 'package:dio/dio.dart';
import 'package:waste_free_home/utils/dio.dart';

class HubService {
  late String baseUrl;
  late Dio _dio;

  bool _isDioInitialized = false;

  HubService() {
    discoverServices();
  }

  Future<void> setupDioClient(address, port) async {
    baseUrl = "http://$address:$port/API";
    _dio = DioClient(baseUrl).dio;
    _isDioInitialized = true;
    print("Dio client setup complete");
  }

  bool get isDioInitialized => _isDioInitialized;

  Future<void> discoverServices() async {
    String type = '_http._tcp';

    try {
      BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
      await discovery.ready;

      discovery.eventStream!.listen((event) async {
        if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
          print('Service found: ${event.service?.toJson()}');
          await event.service!.resolve(discovery.serviceResolver);
        } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
          print('Service resolved: ${event.service?.toJson()}');
          Map<String, dynamic>? serviceInfo = event.service?.toJson();
          if (serviceInfo?["service.name"] == "WasteFreeHomeHTTPHub") {
            String address = serviceInfo?["service.host"];
            String port = serviceInfo!["service.port"].toString();
            await setupDioClient(address, port);
            await discovery.stop();
          }
        } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
          print('Service lost: ${event.service?.toJson()}');
        }
      });

      await discovery.start();
    } catch (e) {
      print('Error during service discovery: $e');
    }
  }


  Future<bool> isOnline() async {
    if (!_isDioInitialized) {
      print('Dio client is not initialized.');
      return false;
    }
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('Error checking if online: $e');
      return false;
    }
  }

  Future<void> updateCredentials(String email, String password) async {
    if (!_isDioInitialized) {
      throw Exception('Dio client is not initialized.');
    }
    try {
      final response = await _dio.put(
        '/update-credentials',
        data: {
          'email': email,
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
