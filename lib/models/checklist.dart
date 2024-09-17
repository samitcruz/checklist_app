// models/checklist.dart
import 'package:safety_check/models/checklist_item.dart';

class Checklist {
  int id;
  String? inspectingStaff;
  String stationName;
  String flightNumber;
  String date;
  List<ChecklistItem>? items;
  DateTime timestamp;

  Checklist(
      {required this.id,
      required this.inspectingStaff,
      required this.stationName,
      required this.flightNumber,
      required this.date,
      this.items,
      required this.timestamp});

  factory Checklist.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List?;
    List<ChecklistItem> items = itemsList != null
        ? itemsList.map((i) => ChecklistItem.fromJson(i)).toList()
        : [];

    return Checklist(
      id: json['id'],
      inspectingStaff: json['inspectingStaff'],
      stationName: json['stationName'],
      flightNumber: json['flightNumber'],
      date: json['date'],
      items: items,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
