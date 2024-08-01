import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_check/api_service.dart';
import 'package:safety_check/models/checklist_item.dart';
import 'package:safety_check/pages/generic_pages/on_arrival_checks.dart';

class PreflightArrivals extends StatefulWidget {
  final String stationName;
  final String flightNumber;
  final String date;
  final int checklistId;

  PreflightArrivals({
    required this.stationName,
    required this.flightNumber,
    required this.date,
    required this.checklistId,
  });

  @override
  _PreflightArrivalsState createState() => _PreflightArrivalsState();
}

class _PreflightArrivalsState extends State<PreflightArrivals> {
  List<ChecklistItem> items = [];
  ApiService apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    items = [
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Lines on the ramp clearly visible',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'FOD & fuel and oil leakage signs Inspection Done',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Serviceable Equipment Ready Out of ERA',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'Equipment have rubber bumpers at the tip that connects to the aircraft body',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Staff ready with PPE',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Marshialler/ADS ready for guide',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Ramp agent ready with incoming CPM',
          yes: false,
          no: false),
    ];
  }

  void _showRemarkDialog(int index) async {
    // ignore: unused_local_variable
    String remarkText = '';
    XFile? imageFile;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Remark'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  remarkText = value;
                },
                decoration: InputDecoration(
                  labelText: 'Enter your remark',
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final XFile? pickedFile =
                          await _picker.pickImage(source: ImageSource.camera);
                      setState(() {
                        imageFile = pickedFile;
                      });
                    },
                    child: Text('Take a Photo'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final XFile? pickedFile =
                          await _picker.pickImage(source: ImageSource.gallery);
                      setState(() {
                        imageFile = pickedFile;
                      });
                    },
                    child: Text('Upload a Photo'),
                  ),
                ],
              ),
              if (imageFile != null) ...[
                SizedBox(height: 10),
                Image.file(
                  File(imageFile!.path),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle saving the remark and image if necessary
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveChecklist() async {
    try {
      for (var item in items) {
        var createDto = item.toCreateDto();
        await apiService.createChecklistItem(widget.checklistId, createDto);
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checklist saved successfully!')));
      Get.to(() => OnArrivalChecks(
            checklistId: widget.checklistId, stationName: '', flightNumber: '',
            date: '', // Pass the checklist ID
          ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save checklist: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preflight Arrivals')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          ChecklistItem item = items[index];
          return ListTile(
            title: Text(item.description),
            subtitle: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: item.yes,
                        onChanged: (bool? value) {
                          setState(() {
                            item.yes = value ?? false;
                            if (item.yes)
                              item.no = false; // Ensure mutual exclusivity
                          });
                        },
                      ),
                      Text('Yes'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: item.no,
                        onChanged: (bool? value) {
                          setState(() {
                            item.no = value ?? false;
                            if (item.no)
                              item.yes = false; // Ensure mutual exclusivity
                          });
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showRemarkDialog(index),
                        child: Text(
                          'Remarks',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveChecklist,
        child: Icon(Icons.save),
      ),
    );
  }
}
