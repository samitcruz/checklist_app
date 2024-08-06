// checklist_item.dart
import 'package:safety_check/models/checklist_item_dto.dart';

class ChecklistItem {
  final int? id;
  final int checklistId;
  final String description;
  bool yes;
  bool no;
  String? remarkText;
  String? remarkImagePath;

  ChecklistItem({
    this.id,
    required this.checklistId,
    required this.description,
    required this.yes,
    required this.no,
    this.remarkText,
    this.remarkImagePath,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      checklistId: json['checklistId'],
      description: json['description'],
      yes: json['yes'],
      no: json['no'],
      remarkText: json['remarkText'],
      remarkImagePath: json['remarkImagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checklistId': checklistId,
      'description': description,
      'yes': yes,
      'no': no,
      'remarkText': remarkText,
      'remarkImagePath': remarkImagePath,
    };
  }

  ChecklistItemCreateDto toCreateDto() {
    return ChecklistItemCreateDto(
      checklistId: checklistId,
      description: description,
      yes: yes,
      no: no,
      remarkText: remarkText,
      remarkImagePath: remarkImagePath,
    );
  }
}
