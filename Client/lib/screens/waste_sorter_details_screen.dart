import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/models/device.dart';
import 'package:waste_free_home/models/waste_sorter_records.dart';
import 'package:waste_free_home/services/device_service.dart';
import 'package:waste_free_home/services/record_service.dart';
import 'package:waste_free_home/utils/helper_methods.dart';
import 'package:waste_free_home/widgets/waste_sorter_level_chart.dart';

@RoutePage()
class DeviceDetailsScreen extends StatefulWidget {
  final String id;

  const DeviceDetailsScreen({super.key, @PathParam('id') required this.id});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  final DeviceService _deviceService = DeviceService();
  final RecordService _recordService = RecordService();
  late Future<Device?> _deviceFuture;
  late Future<Map<String, List<WasteSorterRecord>>> _recordsFuture;
  int _recyclableCount = 0;
  int _recycleRecordsCount = 0;
  double? _lastRecordLevel;
  DateTime? _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime? _endDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _deviceFuture = _deviceService.getDeviceById(widget.id);
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

  Future<Map<String, List<WasteSorterRecord>>> _fetchRecords({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await _recordService.getRecords(
      widget.id,
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
        _lastRecordLevel = levelRecords.last.level;
      }
    });

    return {'recycleRecords': recycleRecords, 'levelRecords': levelRecords};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Device?>(
        future: _deviceFuture,
        builder: (BuildContext context, AsyncSnapshot<Device?> deviceSnapshot) {
          if (deviceSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (deviceSnapshot.hasError) {
            return Center(
              child: Text('Error: ${deviceSnapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          } else if (!deviceSnapshot.hasData || deviceSnapshot.data == null) {
            return const Center(
              child:
                  Text('No device found', style: TextStyle(color: Colors.grey)),
            );
          } else {
            final device = deviceSnapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatDeviceType(device.type),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: device.imageUrl != null
                          ? Image.network(
                              device.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            )
                          : Image.asset(
                              getDefaultDeviceImageUrl(device.type),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              device.description,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Selected Date Range: ${_startDate != null ? formatDate(_startDate!.toLocal()) : 'From'} - ${_endDate != null ? formatDate(_endDate!.toLocal()) : 'To'}',
                                ),
                                IconButton(
                                  onPressed: () => _selectDateRange(context),
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.green,
                                    size: 24.0,
                                    semanticLabel: 'Select date range',
                                  ),
                                  tooltip: "Select date range",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<Map<String, List<WasteSorterRecord>>>(
                            future: _recordsFuture,
                            builder: (BuildContext context,
                                AsyncSnapshot<
                                        Map<String, List<WasteSorterRecord>>>
                                    recordsSnapshot) {
                              if (recordsSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (recordsSnapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${recordsSnapshot.error}',
                                      style:
                                          const TextStyle(color: Colors.red)),
                                );
                              } else if (!recordsSnapshot.hasData ||
                                  recordsSnapshot.data == null ||
                                  recordsSnapshot
                                      .data!['levelRecords']!.isEmpty) {
                                return const Center(
                                  child: Text('No level records found',
                                      style: TextStyle(color: Colors.grey)),
                                );
                              } else {
                                final levelRecords =
                                    recordsSnapshot.data!['levelRecords']
                                        as List<WasteSorterLevelRecord>;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 100,
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 4.0),
                                                      child: Text(
                                                        '$_recyclableCount/$_recycleRecordsCount',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '(${(_recycleRecordsCount / (_recyclableCount == 0 ? 1 : _recyclableCount) * 100).toStringAsFixed(0)}%)',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Text(
                                                  'Items recycled',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            height: 100,
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  _lastRecordLevel != null
                                                      ? '${_lastRecordLevel!.toStringAsFixed(1)}%'
                                                      : 'N/A',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Text(
                                                  'Capacity filled',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: WasteSorterLevelChart(
                                          data: levelRecords),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
