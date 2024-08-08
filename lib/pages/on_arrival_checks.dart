import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_check/Controllers/checklist_controller.dart';
import 'package:safety_check/custom/custom_checkbox.dart';
import 'package:safety_check/models/checklist_item.dart';
import 'package:safety_check/pages/aircraft_fueling.dart';
import 'package:safety_check/pages/help.dart';
import 'package:safety_check/pages/notices.dart';

class OnArrivalChecks extends StatefulWidget {
  final String stationName;
  final String flightNumber;
  final String date;
  final int checklistId;

  OnArrivalChecks({
    required this.stationName,
    required this.flightNumber,
    required this.date,
    required this.checklistId,
  });

  @override
  _OnArrivalChecksState createState() => _OnArrivalChecksState();
}

class _OnArrivalChecksState extends State<OnArrivalChecks> {
  List<ChecklistItem> items = [];
  final ChecklistController controller = Get.find<ChecklistController>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    items = [
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'No staff/Equipment approached before engine off, anti-collision beacon & aircraft is chocked on and marshaller gives clearance.',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Aircraft parked at right spot',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Chocks placed per standard/aircraft type',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Safety Cones placed per standard',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'Check for physical damage on Aircraft before any activity',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'Twice brake checks made while equipment approaches aircraft',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'Reasonable clearance is left between the aircraft and the equipment positioned',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'Stabilizers are set for all equipment positioned to the aircraft ',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'Check for any damage on the door area before opening cabin/cargo door',
          yes: false,
          no: false,
          na: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Equipment are not operated under the aircraft wing. ',
          yes: false,
          no: false,
          na: false),
    ];
    controller.addOnArrivalChecksItems(items);
  }

  void _showRemarkDialog(int index) async {
    TextEditingController remarkController = TextEditingController(
      text: items[index].remarkText ?? '',
    );
    String? imagePath = items[index].remarkImagePath;
    String? imageName =
        imagePath != null ? File(imagePath).uri.pathSegments.last : null;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: TextStyle(color: Color.fromARGB(255, 82, 138, 41)),
          title: Text('Add Remark'),
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
                              color: const Color.fromARGB(255, 82, 138, 41),
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
                      items[index].remarkImagePath = imagePath;
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

    controller.addOnArrivalChecksItems(items);
    Get.to(() => AircraftFueling(
          checklistId: widget.checklistId,
          stationName: widget.stationName,
          flightNumber: widget.flightNumber,
          date: widget.date,
        ));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
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
                case 'Help':
                  Get.to(HelpPage());
                  break;
                case 'Notices':
                  Get.to(NoticesPage());
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'Help',
                child: Text(
                  'Help',
                  style: GoogleFonts.openSans(fontSize: 14),
                ),
              ),
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
          'On Arrival/During Operation',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
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
                    if (item.remarkText != null && item.remarkText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Remark: ${item.remarkText}',
                          style: GoogleFonts.openSans(
                              fontSize: fontSize * 0.8,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (item.remarkImagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.file(
                          File(item.remarkImagePath!),
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
    );
  }
}
