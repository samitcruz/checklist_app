import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safety_check/models/checklist_dto.dart';

import 'package:safety_check/models/checklist_model.dart';

class ApiService {
  static const String _baseUrl = 'https://localhost:7236/api';

  Future<List<Checklist>> getChecklists() async {
    final response = await http.get(Uri.parse('$_baseUrl/Checklist'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Checklist> checklists =
          body.map((dynamic item) => Checklist.fromJson(item)).toList();
      return checklists;
    } else {
      throw Exception('Failed to load checklists');
    }
  }

  Future<Checklist> getChecklist(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/Checklist/$id'));
    if (response.statusCode == 200) {
      return Checklist.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load checklist');
    }
  }

  Future<Checklist> createChecklist(ChecklistDto checklistDto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/Checklist'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(checklistDto.toJson()),
    );
    if (response.statusCode == 201) {
      return Checklist.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create checklist');
    }
  }

  Future<Checklist> updateChecklist(int id, ChecklistDto checklistDto) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/Checklist/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(checklistDto.toJson()),
    );
    if (response.statusCode == 200) {
      return Checklist.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update checklist');
    }
  }

  Future<void> deleteChecklist(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/Checklist/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete checklist');
    }
  }
}
