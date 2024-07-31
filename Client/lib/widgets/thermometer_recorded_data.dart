import 'package:flutter/material.dart';
import 'package:waste_free_home/models/thermometer_records.dart';
import 'package:waste_free_home/services/auth_service.dart';
import 'package:waste_free_home/services/record_service.dart';
import 'package:waste_free_home/utils/helper_methods.dart';
import 'package:waste_free_home/widgets/thermometer_value_chart.dart';
import 'package:waste_free_home/models/record.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ThermometerRecordedData extends StatefulWidget {
  final String deviceId;

  const ThermometerRecordedData({super.key, required this.deviceId});

  @override
  ThermometerRecordedDataState createState() => ThermometerRecordedDataState();
}

class ThermometerRecordedDataState extends State<ThermometerRecordedData> {
  final RecordService _recordService = RecordService();
  final AuthService _authService = AuthService();
  late Future<Map<String, List<Record>>> _recordsFuture;
  double? _lastRecordTemperature;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  late final WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _fetchRecords(startDate: _startDate, endDate: _endDate);
    _establishWebsocketConnection();
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
        _recordsFuture =
            _fetchRecords(startDate: _startDate, endDate: _endDate);
      }
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
        _recordsFuture =
            _fetchRecords(startDate: _startDate, endDate: _endDate);
      });
    }
  }

  Future<Map<String, List<Record>>> _fetchRecords({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await _recordService.getRecords(
      widget.deviceId,
      startDate: startDate,
      endDate: endDate,
    );

    final temperatureRecords = data['temperatureRecords'] as List<ThermometerTemperatureRecord>;

    setState(() {
      if (temperatureRecords.isNotEmpty) {
        _lastRecordTemperature = temperatureRecords.last.temperature;
      }
    });

    return {'temperatureRecords': temperatureRecords};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText:
                  '${formatDate(_startDate.toLocal())} - ${formatDate(_endDate.toLocal())}',
                  suffixIcon: IconButton(
                    icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.green),
                    onPressed: () =>
                        _selectDateRange(context),
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
          builder: (BuildContext context, AsyncSnapshot<Map<String, List<Record>>> recordsSnapshot) {
            if (recordsSnapshot.connectionState == ConnectionState.waiting) {
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Last recorded temperature',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _lastRecordTemperature != null
                                      ? '${_lastRecordTemperature!.toStringAsFixed(1)}°C'
                                      : 'N/A',
                                  style: TextStyle(
                                    color: _lastRecordTemperature != null
                                        ? (_lastRecordTemperature! < 15
                                        ? Colors.lightBlue
                                        : _lastRecordTemperature! > 28
                                        ? Colors.orange
                                        : Colors.black)
                                        : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: ThermometerTemperatureChart(data: temperatureRecords),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}
