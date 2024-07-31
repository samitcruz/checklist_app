// models/checklist_dto.dart
class ChecklistDto {
  String stationName;
  String flightNumber;
  String date;

  ChecklistDto({
    required this.stationName,
    required this.flightNumber,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'stationName': stationName,
      'flightNumber': flightNumber,
      'date': date,
    };
  }
}
