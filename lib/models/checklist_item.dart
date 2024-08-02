import 'dart:convert';
import 'dart:io';

class ChecklistItem {
  final int? id;
  final int checklistId;
  final String description;
  bool yes;
  bool no;
  String? remarkText;
  String? remarkImagePath; // Stores the image path as a string

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

  ChecklistItemCreateDto toCreateDto() {
    return ChecklistItemCreateDto(
      checklistId: checklistId,
      description: description,
      yes: yes,
      no: no,
      remarkText: remarkText?.isEmpty ?? true ? null : remarkText,
      remarkImagePath: remarkImagePath,
    );
  }
}

class ChecklistItemCreateDto {
  final int checklistId;
  final String description;
  final bool yes;
  final bool no;
  final String? remarkText;
  final String? remarkImagePath;

  ChecklistItemCreateDto(
      {required this.checklistId,
      required this.description,
      required this.yes,
      required this.no,
      this.remarkText,
      this.remarkImagePath});

  Map<String, dynamic> toJson() => {
        'checklistId': checklistId,
        'description': description,
        'yes': yes,
        'no': no,
      };
}

class ChecklistItemRemarkDto {
  final String? remarkText;
  final String? remarkImage; // Image path or base64 string

  ChecklistItemRemarkDto({
    this.remarkText,
    this.remarkImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'remarkText': remarkText,
      'remarkImage': remarkImage,
    };
  }

  // Utility function to convert image file to base64 string
  static String? encodeImageToBase64(File? imageFile) {
    if (imageFile == null) return null;
    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
  }
}
