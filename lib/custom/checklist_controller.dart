// checklist_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChecklistController extends GetxController {
  Future<void> saveChecklist(String stationName, String flightNumber, String date) async {
    try {
      var response = await http.post(
        Uri.parse('https://localhost:7236/api/Checklist'), 
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'stationName': stationName,
          'flightNumber': flightNumber,
          'date': date,
        }),
      );

      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Data saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to save data to the server',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save data to the server: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
