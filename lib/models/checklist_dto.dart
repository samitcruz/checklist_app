class ChecklistDto {
  String? inspectingStaff;
  String stationName;
  String flightNumber;
  String date;
  DateTime timestamp;

  ChecklistDto({
    required this.inspectingStaff,
    required this.stationName,
    required this.flightNumber,
    required this.date,
    required List<dynamic> items,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'inspectingStaff': inspectingStaff,
      'stationName': stationName,
      'flightNumber': flightNumber,
      'date': date,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
