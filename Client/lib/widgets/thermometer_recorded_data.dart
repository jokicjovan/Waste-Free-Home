import 'package:flutter/material.dart';
import 'package:waste_free_home/models/thermometer_records.dart';
import 'package:waste_free_home/services/record_service.dart';
import 'package:waste_free_home/utils/helper_methods.dart';
import 'package:waste_free_home/widgets/thermometer_value_chart.dart';
import 'package:waste_free_home/models/record.dart';

class ThermometerRecordedData extends StatefulWidget {
  final String deviceId;

  const ThermometerRecordedData({super.key, required this.deviceId});

  @override
  ThermometerRecordedDataState createState() => ThermometerRecordedDataState();
}

class ThermometerRecordedDataState extends State<ThermometerRecordedData> {
  final RecordService _recordService = RecordService();
  late Future<Map<String, List<Record>>> _recordsFuture;
  double? _lastRecordTemperature;
  DateTime? _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime? _endDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _recordsFuture = _fetchRecords(startDate: _startDate, endDate: _endDate);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _endDate ?? DateTime.now().add(const Duration(days: 1)),
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
                  '${_startDate != null ? formatDate(_startDate!.toLocal()) : 'From'} - ${_endDate != null ? formatDate(_endDate!.toLocal()) : 'To'}',
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
                  Center(
                    child: Card(
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            const Text(
                              'Current Degrees',
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
