class ChecklistDto {
  String? inspectingStaff;
  String stationName;
  String flightNumber;
  String date;

  ChecklistDto({
    required this.inspectingStaff,
    required this.stationName,
    required this.flightNumber,
    required this.date,
    required List<dynamic> items,
  });

  Map<String, dynamic> toJson() {
    return {
      'inspectingStaff': inspectingStaff,
      'stationName': stationName,
      'flightNumber': flightNumber,
      'date': date,
    };
  }
}
