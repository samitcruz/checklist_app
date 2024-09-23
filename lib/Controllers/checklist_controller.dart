import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/models/checklist_item.dart';
import 'package:safety_check/models/checklist_item_dto.dart';
import 'package:safety_check/Services/api_service.dart';

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

    List<ChecklistItemCreateDto> checklistDtos = [];

    try {
      for (var item in allItems) {
        checklistDtos.add(ChecklistItemCreateDto(
          checklistId: item.checklistId,
          description: item.description,
          yes: item.yes,
          no: item.no,
          na: item.na,
          remarkText: item.remarkText,
          remarkImagePath: item.remarkImage,
        ));
      }

      await apiService.createMultipleChecklistItems(checklistDtos);

      Get.snackbar('Success', 'You have submitted the checklist',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit checklist: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
