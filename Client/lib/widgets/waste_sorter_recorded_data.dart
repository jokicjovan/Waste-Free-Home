import 'package:flutter/material.dart';
import 'package:waste_free_home/models/waste_sorter_records.dart';
import 'package:waste_free_home/services/auth_service.dart';
import 'package:waste_free_home/services/record_service.dart';
import 'package:waste_free_home/utils/helper_methods.dart';
import 'package:waste_free_home/widgets/waste_sorter_level_chart.dart';
import 'package:waste_free_home/models/record.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WasteSorterRecordedData extends StatefulWidget {
  final String deviceId;

  const WasteSorterRecordedData({super.key, required this.deviceId});

  @override
  WasteSorterRecordedDataState createState() => WasteSorterRecordedDataState();
}

class WasteSorterRecordedDataState extends State<WasteSorterRecordedData> {
  final RecordService _recordService = RecordService();
  final AuthService _authService = AuthService();
  late Future<Map<String, List<Record>>> _recordsFuture;
  int _recyclableCount = 0;
  int _recycleRecordsCount = 0;
  double? _lastRecyclableLevel;
  double? _lastNonRecyclableLevel;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  late final WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _fetchRecords(startDate: _startDate, endDate: _endDate);
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

    final recycleRecords =
        data['recycleRecords'] as List<WasteSorterRecycleRecord>;
    final levelRecords = data['levelRecords'] as List<WasteSorterLevelRecord>;

    setState(() {
      _recyclableCount = recycleRecords
          .where((record) => record.wasteType == WasteType.RECYCLABLE)
          .length;
      _recycleRecordsCount = recycleRecords.length;

      if (levelRecords.isNotEmpty) {
        _lastRecyclableLevel = levelRecords.last.recyclableLevel;
        _lastNonRecyclableLevel = levelRecords.last.nonRecyclableLevel;
      }
    });

    return {'recycleRecords': recycleRecords, 'levelRecords': levelRecords};
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
                    icon: const Icon(Icons.calendar_today, color: Colors.green),
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
            if (recordsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (recordsSnapshot.hasError) {
              return Center(
                child: Text('Error: ${recordsSnapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            } else if (!recordsSnapshot.hasData ||
                recordsSnapshot.data == null ||
                recordsSnapshot.data!['levelRecords']!.isEmpty) {
              return const Center(
                child: Text('No records found',
                    style: TextStyle(color: Colors.grey)),
              );
            } else {
              final levelRecords = recordsSnapshot.data!['levelRecords']
                  as List<WasteSorterLevelRecord>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                                const Text(
                                  'Items recycled',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: Text(
                                        '$_recyclableCount/$_recycleRecordsCount',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '(${(_recyclableCount / (_recycleRecordsCount == 0 ? 1 : _recycleRecordsCount) * 100).toStringAsFixed(0)}%)',
                                      style: TextStyle(
                                        color: (_recyclableCount /
                                                    (_recycleRecordsCount == 0
                                                        ? 1
                                                        : _recycleRecordsCount) *
                                                    100) <
                                                50
                                            ? Colors.red
                                            : Colors.green,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
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
                                const Text(
                                  textAlign: TextAlign.center,
                                  'Last recorded recyclable capacity filled',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _lastRecyclableLevel != null
                                      ? '${_lastRecyclableLevel!.toStringAsFixed(1)}%'
                                      : 'N/A',
                                  style: TextStyle(
                                    color: _lastRecyclableLevel != null &&
                                            _lastRecyclableLevel! > 80
                                        ? Colors.red
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
                      const SizedBox(height: 8),
                      Expanded(
                        child: Card(
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  textAlign: TextAlign.center,
                                  'Last recorded non-recyclable capacity filled',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _lastNonRecyclableLevel != null
                                      ? '${_lastNonRecyclableLevel!.toStringAsFixed(1)}%'
                                      : 'N/A',
                                  style: TextStyle(
                                    color: _lastNonRecyclableLevel != null &&
                                            _lastNonRecyclableLevel! > 80
                                        ? Colors.red
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
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: WasteSorterLevelChart(data: levelRecords),
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
