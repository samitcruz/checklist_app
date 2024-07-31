// models/checklist_item.dart
class ChecklistItem {
  int id;
  String description;
  bool yes;
  bool no;
  String? remark;

  ChecklistItem({
    required this.id,
    required this.description,
    required this.yes,
    required this.no,
    this.remark,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'],
      description: json['description'],
      yes: json['yes'],
      no: json['no'],
      remark: json['remark'],
    );
  }
}
