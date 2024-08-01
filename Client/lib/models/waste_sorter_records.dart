import 'package:waste_free_home/models/record.dart';

enum WasteType { RECYCLABLE, NON_RECYCLABLE }

class WasteSorterRecycleRecord extends Record {
  final WasteType wasteType;

  WasteSorterRecycleRecord({
    required super.timestamp,
    required this.wasteType,
  });

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
  final double recyclableLevel;
  final double nonRecyclableLevel;

  WasteSorterLevelRecord({
    required super.timestamp,
    required this.recyclableLevel,
    required this.nonRecyclableLevel,
  });

  factory WasteSorterLevelRecord.fromJson(Map<String, dynamic> json) {
    return WasteSorterLevelRecord(
      timestamp: DateTime.parse(json['timestamp']),
      recyclableLevel: json['recyclable_level'],
      nonRecyclableLevel: json['non_recyclable_level'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'recyclable_level': recyclableLevel,
      'non_recyclable_level': nonRecyclableLevel,
    };
  }
}
