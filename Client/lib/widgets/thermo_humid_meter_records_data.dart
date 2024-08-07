import 'package:flutter/material.dart';
import 'package:waste_free_home/models/thermo_humid_meter_records.dart';
import 'package:waste_free_home/services/auth_service.dart';
import 'package:waste_free_home/services/record_service.dart';
import 'package:waste_free_home/utils/helper_methods.dart';
import 'package:waste_free_home/widgets/thermo_humid_meter_chart.dart';
import 'package:waste_free_home/models/record.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ThermoHumidMeterRecordsData extends StatefulWidget {
  final String deviceId;

  const ThermoHumidMeterRecordsData({super.key, required this.deviceId});

  @override
  ThermoHumidMeterRecordsDataState createState() => ThermoHumidMeterRecordsDataState();
}

class ThermoHumidMeterRecordsDataState extends State<ThermoHumidMeterRecordsData> {
  final RecordService _recordService = RecordService();
  final AuthService _authService = AuthService();
  late Future<Map<String, List<Record>>> _recordsFuture;
  late Future<Map<String, List<Record>>> _latestRecordsFuture;
  double? _lastTemperature;
  double? _lastHumidity;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  late final WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _fetchRecords(startDate: _startDate, endDate: _endDate);
    _latestRecordsFuture = _fetchLatestRecords();
    _establishWebsocketConnection();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Future<void> _establishWebsocketConnection() async {
    final String? accessToken = await _authService.getToken();
    _channel = IOWebSocketChannel.connect(
      Uri.parse(_recordService.getWsConnection(widget.deviceId)),
      headers: {
        'Authorization': "Bearer $accessToken",
      },
    );
    _channel.stream.listen((message) {
      if (_endDate.isAfter(DateTime.now())) {
        setState(() {
          _recordsFuture = _fetchRecords(startDate: _startDate, endDate: _endDate);
        });
      }
      setState(() {
        _latestRecordsFuture = _fetchLatestRecords();
      });
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.start.year, picked.start.month, picked.start.day, 0, 0, 0);
        _endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59, 999);

        _recordsFuture = _fetchRecords(startDate: _startDate, endDate: _endDate);
      });
    }
  }

  Future<Map<String, List<Record>>> _fetchRecords({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await _recordService.fetchRecords(
      widget.deviceId,
      startDate: startDate,
      endDate: endDate,
    );

    final thermohumidRecords = data['thermohumidRecords'] as List<ThermoHumidMeterRecord>;

    return {'thermohumidRecords': thermohumidRecords};
  }

  Future<Map<String, List<Record>>> _fetchLatestRecords() async {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final data = await _recordService.fetchRecords(
      widget.deviceId,
      startDate: last24Hours,
      endDate: now,
    );

    final thermohumidRecords = data['thermohumidRecords'] as List<ThermoHumidMeterRecord>;

    if (thermohumidRecords.isNotEmpty) {
      setState(() {
        _lastTemperature = thermohumidRecords.last.temperature;
        _lastHumidity = thermohumidRecords.last.humidity;
      });
    }
    return {'thermohumidRecords': thermohumidRecords};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Text(
                      'Latest data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, List<Record>>>(
                future: _latestRecordsFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, List<Record>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)),
                    );
                  } else if (!snapshot.hasData ||
                      snapshot.data!['thermohumidRecords']!.isEmpty) {
                    return const Center(
                      child: Text('No data available for the last 24 hours',
                          style: TextStyle(color: Colors.grey)),
                    );
                  } else {
                    final thermohumidRecords = snapshot.data!['thermohumidRecords']
                    as List<ThermoHumidMeterRecord>;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 6,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _lastTemperature != null
                                        ? '${_lastTemperature!.toStringAsFixed(1)}°C'
                                        : 'N/A',
                                    style: TextStyle(
                                      color: _lastTemperature != null
                                          ? (_lastTemperature! < 15
                                          ? Colors.lightBlue
                                          : _lastTemperature! > 28
                                          ? Colors.deepOrange
                                          : Colors.green)
                                          : Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    textAlign: TextAlign.center,
                                    'Temperature',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            elevation: 6,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _lastHumidity != null
                                        ? '${_lastHumidity!.toStringAsFixed(1)}%'
                                        : 'N/A',
                                    style: TextStyle(
                                      color: _lastHumidity != null
                                          ? (_lastHumidity! < 30
                                          ? Colors.orange
                                          : _lastHumidity! > 50
                                          ? Colors.blue
                                          : Colors.green)
                                          : Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    textAlign: TextAlign.center,
                                    'Humidity',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Text(
                      'Historical data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText:
                        '${formatDate(_startDate.toLocal())} - ${formatDate(_endDate.toLocal())}',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today,
                              color: Colors.green),
                          onPressed: () => _selectDateRange(context),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<Map<String, List<Record>>>(
                future: _recordsFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, List<Record>>> recordsSnapshot) {
                  if (recordsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (recordsSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${recordsSnapshot.error}',
                          style: const TextStyle(color: Colors.red)),
                    );
                  } else if (!recordsSnapshot.hasData ||
                      recordsSnapshot.data == null ||
                      recordsSnapshot.data!['thermohumidRecords']!.isEmpty) {
                    return const Center(
                      child: Text('No records found',
                          style: TextStyle(color: Colors.grey)),
                    );
                  } else {
                    final thermohumidRecords = recordsSnapshot.data!['thermohumidRecords']
                    as List<ThermoHumidMeterRecord>;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child:
                      ThermoHumidMeterChart(data: thermohumidRecords),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
