import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_check/Controllers/checklist_controller.dart';
import 'package:safety_check/Services/api_service.dart';
import 'package:safety_check/custom/custom_checkbox.dart';
import 'package:safety_check/models/checklist_item.dart';
import 'package:safety_check/pages/on_arrival_checks.dart';
import 'package:safety_check/pages/notices.dart';

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
  final ImagePicker _picker = ImagePicker();
  final ChecklistController controller = Get.find<ChecklistController>();

  @override
  void initState() {
    super.initState();
    items = [
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Lines on the ramp clearly visible',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'FOD(Foreign Object Debris) & fuel and oil leakage signs Inspection Done',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Serviceable Equipment Ready Out of ERA',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'Equipment have rubber bumpers at the tip that connects to the aircraft body',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Staff ready with PPE',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Marshaller/ADS ready for guide',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Ramp agent ready with incoming CPM',
          yes: false,
          no: false,
          na: false),
    ];
    controller.addPreflightArrivalsItems(items);
  }

  void _showRemarkDialog(int index) async {
    TextEditingController remarkController = TextEditingController(
      text: items[index].remarkText ?? '',
    );
    String? imagePath = items[index].remarkImage;
    String? imageName =
        imagePath != null ? File(imagePath).uri.pathSegments.last : null;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: TextStyle(color: Color.fromARGB(255, 82, 138, 41)),
          title: Text('Add Remark,'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: remarkController,
                onChanged: (value) {
                  items[index].remarkText = value;
                },
                decoration: InputDecoration(
                  labelText: 'Enter your remark',
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final XFile? pickedFile = await showModalBottomSheet<XFile?>(
                    context: context,
                    builder: (BuildContext context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.camera_alt,
                              color: const Color.fromARGB(255, 82, 138, 41),
                            ),
                            title: Text('Take a Photo'),
                            onTap: () async {
                              Navigator.pop(
                                  context,
                                  await _picker.pickImage(
                                      source: ImageSource.camera));
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.photo_library,
                              color: Color.fromARGB(255, 82, 138, 41),
                            ),
                            title: Text('Upload a Photo'),
                            onTap: () async {
                              Navigator.pop(
                                  context,
                                  await _picker.pickImage(
                                      source: ImageSource.gallery));
                            },
                          ),
                        ],
                      );
                    },
                  );
                  if (pickedFile != null) {
                    setState(() {
                      imagePath = pickedFile.path;
                      imageName = pickedFile.name;
                      items[index].remarkImage = imagePath;
                    });
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.camera_alt,
                        color: const Color.fromARGB(255, 82, 138, 41)),
                    SizedBox(width: 10),
                    Text(
                      imageName != null
                          ? 'Selected Image: $imageName'
                          : 'Select an Image',
                      style: GoogleFonts.openSans(fontSize: 16),
                    ),
                  ],
                ),
              ),
              if (imagePath != null) ...[
                SizedBox(height: 10),
                Image.file(
                  File(imagePath!),
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
              child: Text('Cancel',
                  style:
                      TextStyle(color: const Color.fromARGB(255, 82, 138, 41))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  items[index].remarkText = remarkController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save',
                  style:
                      TextStyle(color: const Color.fromARGB(255, 82, 138, 41))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteChecklist() async {
    final apiService = ApiService();

    try {
      await apiService.deleteChecklist(widget.checklistId);
      Get.back();
    } catch (e) {}
  }

  void _saveChecklist() async {
    for (var item in items) {
      if (!item.yes && !item.no && !item.na) {
        Get.snackbar(
          'Incomplete Checklist',
          'Please complete all checklist items before proceeding',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    controller.addPreflightArrivalsItems(items);
    Get.to(() => OnArrivalChecks(
          checklistId: widget.checklistId,
          stationName: widget.stationName,
          flightNumber: widget.flightNumber,
          date: widget.date,
        ));
  }

  // Future<void> _handlePop() async {
  //   await _deleteChecklist();
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              await _deleteChecklist();
              Get.back();
            },
          ),
          actions: [
            PopupMenuButton<String>(
              iconColor: Colors.white,
              color: Colors.white,
              iconSize: 30,
              onSelected: (String result) {
                switch (result) {
                  case 'Notices':
                    Get.to(() => NoticesPage());
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'Notices',
                  child: Text(
                    'Notices',
                    style: GoogleFonts.openSans(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
          backgroundColor: const Color.fromARGB(255, 82, 138, 41),
          title: Text(
            'Preflight Arrivals',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              textStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _saveChecklist,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 82, 138, 41),
                  ),
                  child: Text(
                    'Next Section',
                    style: GoogleFonts.openSans(),
                  ),
                ),
              );
            }

            ChecklistItem item = items[index];
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: 150),
              child: Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${item.description}',
                        style: GoogleFonts.openSans(fontSize: fontSize),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: CustomCheckbox(
                              value: item.yes,
                              onChanged: (bool? value) {
                                setState(() {
                                  item.yes = value!;
                                  item.no = false;
                                  item.na = false;
                                  print(
                                      'Yes: ${item.yes}, No: ${item.no}, NA: ${item.na}');
                                });
                              },
                              label: 'Yes',
                            ),
                          ),
                          Expanded(
                            child: CustomCheckbox(
                              value: item.no,
                              onChanged: (bool? value) {
                                setState(() {
                                  item.no = value!;
                                  item.yes = false;
                                  item.na = false;
                                  print(
                                      'Yes: ${item.yes}, No: ${item.no}, NA: ${item.na}');
                                });
                              },
                              label: 'No',
                              isNoCheckbox: true,
                            ),
                          ),
                          Expanded(
                            child: CustomCheckbox(
                              value: item.na,
                              onChanged: (bool? value) {
                                setState(() {
                                  item.na = value!;
                                  item.yes = false;
                                  item.no = false;
                                  print(
                                      'Yes: ${item.yes}, No: ${item.no}, NA: ${item.na}');
                                });
                              },
                              label: 'NA',
                              isNaCheckbox: true,
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _showRemarkDialog(index),
                          icon: Icon(Icons.add_comment,
                              color: const Color.fromARGB(255, 82, 138, 41)),
                          label: Text('Add Remark',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 82, 138, 41)),
                              )),
                        ),
                      ),
                      if (item.remarkText != null &&
                          item.remarkText!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Remark: ${item.remarkText}',
                            style: GoogleFonts.openSans(
                                fontSize: fontSize * 0.8,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      if (item.remarkImage != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Image.file(
                            File(item.remarkImage!),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
