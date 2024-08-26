import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:safety_check/Services/authentication_service.dart';
import 'package:safety_check/models/checklist_dto.dart';
import 'package:safety_check/models/checklist.dart';
import 'package:http_parser/http_parser.dart';
import 'package:safety_check/models/checklist_item.dart';
import 'package:safety_check/models/checklist_item_dto.dart';

class ApiService {
  static const String _baseUrl = 'https://10.0.2.2:7148/api/v1';
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Future<List<Checklist>> getChecklists() async {
    final tenant = dotenv.env['tenant'];
    final clientClaim = dotenv.env['clientclaim'];
    final accessToken = (await _storage.read(key: 'clientAccessToken'))?.trim();
    final idToken = (await _storage.read(key: 'idToken'))?.trim();

    // Get the username from secure storage
    final authService = AuthenticationService();
    final userInfo = await authService.getCurrentUserInfo();
    final username = userInfo['username']?.trim().toLowerCase();

    final response = await http.get(
      Uri.parse('$_baseUrl/Checklist/GetAll'),
      headers: {
        'idToken': '$idToken',
        'accessToken': '$accessToken',
        'tenant': tenant ?? '',
        'clientclaim': clientClaim ?? '',
      },
    );

    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Checklist> checklists =
          body.map((dynamic item) => Checklist.fromJson(item)).toList();

      // Filter the checklists based on the username
      List<Checklist> filteredChecklists = checklists.where((checklist) {
        // Compare the inspectingStaff field with the username
        return checklist.inspectingStaff?.toLowerCase() == username;
      }).toList();

      return filteredChecklists;
    } else {
      throw Exception('Failed to load checklists');
    }
  }

  Future<List<ChecklistItem>> getChecklistItems(int checklistId) async {
    final tenant = dotenv.env['tenant'];
    final clientClaim = dotenv.env['clientclaim'];
    final accessToken = (await _storage.read(key: 'clientAccessToken'))?.trim();
    final idToken = (await _storage.read(key: 'idToken'))?.trim();
    final response = await http.get(
      Uri.parse('$_baseUrl/ChecklistItem/by-checklist/$checklistId/'),
      headers: {
        'idToken': '$idToken',
        'accessToken': '$accessToken',
        'tenant': tenant ?? '',
        'clientclaim': clientClaim ?? '',
      },
    );
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      List<dynamic> body = jsonDecode(response.body);
      List<ChecklistItem> checklistItems =
          body.map((dynamic item) => ChecklistItem.fromJson(item)).toList();
      return checklistItems;
    } else {
      print(
          'Failed to load checklist items with status code: ${response.statusCode}');
      throw Exception('Failed to load checklist items');
    }
  }

  Future<int> createChecklist(ChecklistDto checklistDto,
      {required String? inspectingStaff,
      required String flightNumber,
      required String stationName,
      required String date}) async {
    final tenant = dotenv.env['tenant'];
    final clientClaim = dotenv.env['clientclaim'];
    final accessToken = (await _storage.read(key: 'clientAccessToken'))?.trim();
    final idToken = (await _storage.read(key: 'idToken'))?.trim();
    final response = await http.post(
      Uri.parse('$_baseUrl/Checklist/Create'),
      headers: {
        'Content-Type': 'application/json',
        'idToken': '$idToken',
        'accessToken': '$accessToken',
        'tenant': tenant ?? '',
        'clientclaim': clientClaim ?? '',
      },
      body: jsonEncode(checklistDto.toJson()),
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['id'];
    } else {
      throw Exception('Failed to create checklist');
    }
  }

  Future<void> createChecklistItem(ChecklistItemCreateDto createDto) async {
    final tenant = dotenv.env['tenant'];
    final clientClaim = dotenv.env['clientclaim'];
    final accessToken = (await _storage.read(key: 'clientAccessToken'))?.trim();
    final idToken = (await _storage.read(key: 'idToken'))?.trim();
    var uri = Uri.parse('$_baseUrl/ChecklistItem/Create');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'idToken': '$idToken',
      'accessToken': '$accessToken',
      'tenant': tenant ?? '',
      'clientclaim': clientClaim ?? '',
    });

    request.fields['ChecklistId'] = createDto.checklistId.toString();
    request.fields['Description'] = createDto.description;
    request.fields['Yes'] = createDto.yes.toString();
    request.fields['No'] = createDto.no.toString();
    request.fields['Na'] = createDto.na.toString();
    if (createDto.remarkText != null) {
      request.fields['RemarkText'] = createDto.remarkText!;
    } else {
      request.fields['RemarkText'] = '';
    }

    if (createDto.remarkImagePath != null) {
      var file = await http.MultipartFile.fromPath(
        'RemarkImage',
        createDto.remarkImagePath!,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(file);
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to create checklist item: ${response.statusCode} - $responseBody');
      }
      print('Response: $responseBody');
    } catch (e) {
      print('Error during API request: $e');
      throw Exception('Error during API request: $e');
    }
  }

  Future<void> deleteChecklist(int id) async {
    final tenant = dotenv.env['tenant'];
    final clientClaim = dotenv.env['clientclaim'];
    final accessToken = (await _storage.read(key: 'clientAccessToken'))?.trim();
    final idToken = (await _storage.read(key: 'idToken'))?.trim();
    final Uri url = Uri.parse('$_baseUrl/Checklist/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'idToken': '$idToken',
          'accessToken': '$accessToken',
          'tenant': tenant ?? '',
          'clientclaim': clientClaim ?? '',
        },
      );

      if (response.statusCode == 200) {
        print('Checklist deleted successfully');
      } else {
        print(
            'Failed to delete checklist. Status code: ${response.statusCode}');
        throw Exception('Failed to delete checklist: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error deleting checklist: $e');
      throw Exception('Error deleting checklist: $e');
    }
  }
}

  // Future<Checklist> updateChecklist(int id, ChecklistDto checklistDto) async {
  //   final response = await http.put(
  //     Uri.parse('$_baseUrl/Checklist/$id'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(checklistDto.toJson()),
  //   );
  //   if (response.statusCode == 200) {
  //     return Checklist.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to update checklist');
  //   }
  // }

  // Future<Checklist> getChecklist(int id) async {
  //   final response = await http.get(Uri.parse('$_baseUrl/Checklist/$id'));
  //   if (response.statusCode == 200) {
  //     return Checklist.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to load checklist');
  //   }
  // }



//   Future<void> saveChecklistData(
//       String stationName,
//       String flightNumber,
//       String date,
//       List<Map<String, dynamic>> checklistStatus,
//       String title) async {
//     try {
//       final url = Uri.parse('$_baseUrl/Checklist');
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'stationName': stationName,
//           'flightNumber': flightNumber,
//           'date': date,
//           'checklistStatus': checklistStatus,
//           'title': title,
//         }),
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Failed to save checklist data');
//       }
//     } catch (e) {
//       throw Exception('Error saving checklist data: $e');
//     }
//   }
// }

