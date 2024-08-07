// checklist_item_dto.dart
import 'dart:convert';
import 'dart:io';

class ChecklistItemCreateDto {
  final int checklistId;
  final String description;
  final bool yes;
  final bool no;
  final bool na;
  final String? remarkText;
  final String? remarkImagePath;

  ChecklistItemCreateDto({
    required this.checklistId,
    required this.description,
    required this.yes,
    required this.no,
    required this.na,
    this.remarkText,
    this.remarkImagePath,
  });

  Map<String, dynamic> toJson() => {
        'checklistId': checklistId,
        'description': description,
        'yes': yes,
        'no': no,
        'na': na,
        'remarkText': remarkText ?? '',
        'remarkImagePath': remarkImagePath ?? '',
      };

  static String? encodeImageToBase64(File? imageFile) {
    if (imageFile == null) return null;
    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
  }
}
