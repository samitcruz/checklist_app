import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/models/checklist_item.dart';
import 'package:safety_check/models/checklist_item_dto.dart';
import 'package:safety_check/pages/Services/api_service.dart';

class ChecklistController extends GetxController {
  var preflightArrivalsItems = <ChecklistItem>[].obs;
  var onArrivalChecksItems = <ChecklistItem>[].obs;
  var aircraftFuelingItems = <ChecklistItem>[].obs;
  var readyForDepartureItems = <ChecklistItem>[].obs;

  final ApiService apiService = ApiService();

  void addPreflightArrivalsItems(List<ChecklistItem> items) {
    preflightArrivalsItems.assignAll(items);
  }

  void addOnArrivalChecksItems(List<ChecklistItem> items) {
    onArrivalChecksItems.assignAll(items);
  }

  void addAircraftFuelingItems(List<ChecklistItem> items) {
    aircraftFuelingItems.assignAll(items);
  }

  void addReadyForDepartureItems(List<ChecklistItem> items) {
    readyForDepartureItems.assignAll(items);
  }

  Future<void> saveChecklistItems() async {
    final allItems = [
      ...preflightArrivalsItems,
      ...onArrivalChecksItems,
      ...aircraftFuelingItems,
      ...readyForDepartureItems,
    ];

    try {
      for (var item in allItems) {
        var createDto = ChecklistItemCreateDto(
          checklistId: item.checklistId,
          description: item.description,
          yes: item.yes,
          no: item.no,
          na: item.na,
          remarkText: item.remarkText,
          remarkImagePath: item.remarkImagePath,
        );

        await apiService.createChecklistItem(createDto);
      }
      Get.snackbar('Success', 'You have submitted the checklist',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar(
          'Error', 'Please complete all checklist items before proceeding',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
