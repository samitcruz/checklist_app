class ChecklistItem {
  final int checklistId; // Correct parameter name
  final String description;
  bool yes;
  bool no;
  String? remark;

  ChecklistItem({
    required this.checklistId,
    required this.description,
    required this.yes,
    required this.no,
    this.remark,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      checklistId: json['checklistId'],
      description: json['description'],
      yes: json['yes'],
      no: json['no'],
      remark: json['remark'],
    );
  }

  ChecklistItemCreateDto toCreateDto() {
    return ChecklistItemCreateDto(
      checklistId: checklistId,
      description: description,
      yes: yes,
      no: no,
    );
  }
}

class ChecklistItemCreateDto {
  final int checklistId;
  final String description;
  final bool yes;
  final bool no;

  ChecklistItemCreateDto({
    required this.checklistId,
    required this.description,
    required this.yes,
    required this.no,
  });

  Map<String, dynamic> toJson() => {
        'checklistId': checklistId,
        'description': description,
        'yes': yes,
        'no': no,
      };
}

