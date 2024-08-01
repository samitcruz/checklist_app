import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_check/custom/custom_checkbox.dart';
import 'package:safety_check/pages/help.dart';
import 'package:safety_check/pages/notices.dart';
import 'package:safety_check/pages/main_page.dart';
import 'package:safety_check/api_service.dart';

class ChecklistPage extends StatefulWidget {
  final String title;
  final List<String> items;
  final Widget nextPage;
  final bool isLastPage;
  final String stationName;
  final String flightNumber;
  final String date;
  final RxList<Map<String, dynamic>> checklistStatus;
  final int totalItems;

  ChecklistPage({
    required this.title,
    required this.items,
    required this.nextPage,
    required this.stationName,
    required this.flightNumber,
    required this.date,
    this.isLastPage = false,
  })  : totalItems = items.length,
        checklistStatus = RxList<Map<String, dynamic>>(
          List.generate(
            items.length,
            (index) => {'Yes': false, 'No': false, 'Remark': ''},
          ),
        );

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final ApiService apiService = ApiService();

  void _showRemarkDialog(int index) async {
    TextEditingController remarkController = TextEditingController();
    remarkController.text = widget.checklistStatus[index]['Remark'] ?? '';
    XFile? imageFile;

    // Show dialog to enter remark and select image
    await Get.defaultDialog(
      title: 'Enter Remark',
      titleStyle: GoogleFonts.openSans(),
      content: Column(
        children: [
          TextField(
            controller: remarkController,
            decoration: InputDecoration(
              hintText: 'Enter Remark',
              hintStyle: GoogleFonts.openSans(),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final picker = ImagePicker();
              imageFile = await picker.pickImage(source: ImageSource.gallery);
              if (imageFile != null) {
                setState(() {
                  widget.checklistStatus[index]['Image'] = imageFile!.path;
                });
              }
            },
            child: Text('Select an Image'),
          ),
          if (imageFile != null) ...[
            SizedBox(height: 16),
            Image.file(File(imageFile!.path)),
          ],
        ],
      ),
      buttonColor: Color.fromARGB(255, 82, 138, 41),
      textConfirm: 'Save',
      confirmTextColor: Colors.white,
      onConfirm: () {
        widget.checklistStatus[index]['Remark'] = remarkController.text;
        widget.checklistStatus[index]['Image'] = imageFile?.path;
        widget.checklistStatus.refresh();
        Get.back();
      },
    );
  }

  bool _isChecklistComplete() {
    for (var status in widget.checklistStatus) {
      if (!status['Yes'] && !status['No']) {
        return false;
      }
    }
    return true;
  }

  void _handleNextSection() {
    if (_isChecklistComplete()) {
      _saveChecklistData();

      if (widget.isLastPage) {
        Get.offAll(MainPage());
        Get.snackbar(
          'Success',
          'You have submitted the checklist',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.to(widget.nextPage);
      }
    } else {
      Get.snackbar(
        'Error',
        'Please complete all checklist items before proceeding',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveChecklistData() async {
    try {
      await apiService.saveChecklistData(
        widget.stationName,
        widget.flightNumber,
        widget.date,
        widget.checklistStatus,
        widget.title,
      );
      print("Checklist data saved successfully");
    } catch (e) {
      print("Error saving checklist data: $e");
    }
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
          widget.title,
          style: GoogleFonts.openSans(
            fontSize: fontSize,
            textStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.items[index],
                                style: GoogleFonts.openSans(fontSize: 16),
                              ),
                            ),
                            CustomCheckbox(
                              textStyle: GoogleFonts.openSans(fontSize: 16),
                              value: widget.checklistStatus[index]['Yes'],
                              onChanged: (value) {
                                widget.checklistStatus[index]['Yes'] = value!;
                                if (value) {
                                  widget.checklistStatus[index]['No'] = false;
                                }
                                widget.checklistStatus.refresh();
                              },
                              label: 'Yes',
                            ),
                            SizedBox(width: 16),
                            CustomCheckbox(
                              textStyle: GoogleFonts.openSans(fontSize: 16),
                              value: widget.checklistStatus[index]['No'],
                              onChanged: (value) {
                                widget.checklistStatus[index]['No'] = value!;
                                if (value) {
                                  widget.checklistStatus[index]['Yes'] = false;
                                }
                                widget.checklistStatus.refresh();
                              },
                              label: 'No',
                              isNoCheckbox: true,
                            ),
                            SizedBox(width: 10),
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
                      );
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleNextSection,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 82, 138, 41),
                ),
                child: Text(
                  widget.isLastPage ? 'Submit Checklist' : 'Next Section',
                  style: GoogleFonts.openSans(),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
