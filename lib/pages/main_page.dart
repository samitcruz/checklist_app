import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:safety_check/pages/generic_pages/preflight_arrivals.dart';
import 'package:safety_check/pages/history.dart';
import 'help.dart';
import 'notices.dart';

// ignore: must_be_immutable
class MainPage extends StatelessWidget {
  final TextEditingController stationController = TextEditingController();
  final TextEditingController flightNumberController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(255, 82, 138, 41),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  Future<void> _saveToFirestore() async {
    try {
      String stationName = stationController.text;
      String flightNumber = flightNumberController.text;
      String date = dateController.text;

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('inspections')
          .doc(stationName)
          .collection('flights')
          .doc(flightNumber)
          .collection('dates')
          .doc(date);

      await docRef.set({
        'station': stationName,
        'flightNumber': flightNumber,
        'date': date,
      });

      print("Data saved successfully");

      Get.to(() => PreflightArrivals(
            stationName: stationName,
            flightNumber: flightNumber,
            date: date,
          ));
    } catch (e) {
      print("Error saving data to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.home,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {},
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
                case 'History':
                  Get.to(HistoryPage());
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'Help',
                child: Text('Help', style: GoogleFonts.openSans(fontSize: 14)),
              ),
              PopupMenuItem<String>(
                value: 'Notices',
                child:
                    Text('Notices', style: GoogleFonts.openSans(fontSize: 14)),
              ),
              PopupMenuItem<String>(
                value: 'History',
                child:
                    Text('History', style: GoogleFonts.openSans(fontSize: 14)),
              ),
            ],
          ),
        ],
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 82, 138, 41),
        title: Text(
          'Take an Inspection',
          style: GoogleFonts.openSans(
            fontSize: fontSize,
            textStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Image.asset('images/et.png')),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(15)),
                          child: TextFormField(
                            controller: stationController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 20),
                                hintText: 'Station Name',
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(15)),
                          child: TextFormField(
                            controller: flightNumberController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 20),
                                hintText: 'Flight Number',
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(15)),
                          child: TextFormField(
                            onTap: () {
                              _selectDate(context);
                            },
                            readOnly: true,
                            controller: dateController,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 20, top: 12),
                              hintText: 'Date (yyyy-mm-dd)',
                              border: InputBorder.none,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _selectDate(context);
                                },
                                child: Icon(Icons.calendar_today,
                                    size: 20, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (stationController.text.isNotEmpty &&
                          flightNumberController.text.isNotEmpty &&
                          dateController.text.isNotEmpty) {
                        await _saveToFirestore();
                      } else {
                        Get.snackbar(
                          'Error',
                          'Please fill all fields before proceeding',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 82, 138, 41),
                    ),
                    child: Text(
                      'Start Checklist',
                      style: GoogleFonts.openSans(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
