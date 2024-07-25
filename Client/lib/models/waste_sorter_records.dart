import 'package:waste_free_home/models/record.dart';

enum WasteType { RECYCLABLE, NON_RECYCLABLE }

class WasteSorterRecycleRecord extends Record {
  final WasteType wasteType;

  WasteSorterRecycleRecord({
    required DateTime timestamp,
    required this.wasteType,
  }) : super(timestamp: timestamp);

  factory WasteSorterRecycleRecord.fromJson(Map<String, dynamic> json) {
    return WasteSorterRecycleRecord(
      timestamp: DateTime.parse(json['timestamp']),
      wasteType: WasteType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            json['waste_type'].toUpperCase(),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'waste_type': wasteType.toString().split('.').last.toUpperCase(),
    };
  }
}

class WasteSorterLevelRecord extends Record {
  final double level;

  WasteSorterLevelRecord({
    required DateTime timestamp,
    required this.level,
  }) : super(timestamp: timestamp);

  factory WasteSorterLevelRecord.fromJson(Map<String, dynamic> json) {
    return WasteSorterLevelRecord(
      timestamp: DateTime.parse(json['timestamp']),
      level: json['level'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'level': level,
    };
  }
}
