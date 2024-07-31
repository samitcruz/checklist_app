// models/checklist.dart
import 'package:safety_check/models/checklist_item.dart';

class Checklist {
  int id;
  String stationName;
  String flightNumber;
  String date;
  List<ChecklistItem> items;

  Checklist({
    required this.id,
    required this.stationName,
    required this.flightNumber,
    required this.date,
    required this.items,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<ChecklistItem> items =
        itemsList.map((i) => ChecklistItem.fromJson(i)).toList();

    return Checklist(
      id: json['id'],
      stationName: json['stationName'],
      flightNumber: json['flightNumber'],
      date: json['date'],
      items: items,
    );
  }
}
