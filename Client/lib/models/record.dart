class Record {
  final DateTime timestamp;

  Record({required this.timestamp});

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
    };
  }
}