import 'package:flutter/material.dart';
import 'package:waste_free_home/models/thermometer_records.dart';
import 'package:waste_free_home/services/auth_service.dart';
import 'package:waste_free_home/services/record_service.dart';
import 'package:waste_free_home/utils/helper_methods.dart';
import 'package:waste_free_home/widgets/thermometer_temperature_chart.dart';
import 'package:waste_free_home/models/record.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ThermometerRecordsData extends StatefulWidget {
  final String deviceId;

  const ThermometerRecordsData({super.key, required this.deviceId});

  @override
  ThermometerRecordsDataState createState() => ThermometerRecordsDataState();
}

class ThermometerRecordsDataState extends State<ThermometerRecordsData> {
  final RecordService _recordService = RecordService();
  final AuthService _authService = AuthService();
  late Future<Map<String, List<Record>>> _recordsFuture;
  late Future<Map<String, List<Record>>> _latestRecordsFuture;
  double? _lastTemperature;
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
        _startDate = picked.start;
        _endDate = picked.end;
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

    final temperatureRecords = data['temperatureRecords'] as List<ThermometerTemperatureRecord>;

    return {'temperatureRecords': temperatureRecords};
  }

  Future<Map<String, List<Record>>> _fetchLatestRecords() async {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final data = await _recordService.fetchRecords(
      widget.deviceId,
      startDate: last24Hours,
      endDate: now,
    );

    final temperatureRecords = data['temperatureRecords'] as List<ThermometerTemperatureRecord>;

    if (temperatureRecords.isNotEmpty) {
      setState(() {
        _lastTemperature = temperatureRecords.last.temperature;
      });
    }

    return {'temperatureRecords': temperatureRecords};
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
                      snapshot.data!['temperatureRecords']!.isEmpty) {
                    return const Center(
                      child: Text('No data available for the last 24 hours',
                          style: TextStyle(color: Colors.grey)),
                    );
                  } else {
                    final temperatureRecords = snapshot.data!['temperatureRecords']
                    as List<ThermometerTemperatureRecord>;
                    return Card(
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
                                    ? Colors.orange
                                    : Colors.black)
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
                      recordsSnapshot.data!['temperatureRecords']!.isEmpty) {
                    return const Center(
                      child: Text('No records found',
                          style: TextStyle(color: Colors.grey)),
                    );
                  } else {
                    final temperatureRecords = recordsSnapshot.data!['temperatureRecords']
                    as List<ThermometerTemperatureRecord>;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child:
                      ThermometerTemperatureChart(data: temperatureRecords),
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
