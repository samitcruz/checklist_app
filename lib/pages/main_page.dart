import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/Services/api_service.dart';
import 'package:safety_check/Services/authentication_service.dart';
import 'package:safety_check/Services/station_loader.dart';
import 'package:safety_check/models/checklist_dto.dart';
import 'package:safety_check/pages/preflight_arrivals.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notices.dart';
import 'history.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController flightNumberController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final ApiService apiService = ApiService();
  final AuthenticationService _authService = AuthenticationService();
  String? username;
  String? email;

  DateTime selectedDate = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  String? selectedStation;
  List<String> stationNames = [];

  @override
  void initState() {
    super.initState();
    _loadStationNames();
    _loadUserInfo();
  }

  Future<void> _loadStationNames() async {
    try {
      stationNames = await loadStationNames();
      setState(() {});
    } catch (e) {}
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _authService.getCurrentUserInfo();
    setState(() {
      username = userInfo['username']!;
      email = userInfo['email']!;
    });
  }

  @override
  void dispose() {
    flightNumberController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime yesterday = today.subtract(Duration(days: 1));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: yesterday,
      lastDate: today,
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
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  Future<void> _saveToAPI() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          Get.snackbar(
            'No Internet',
            'Please check your internet connection and try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        String stationName = selectedStation!;
        String flightNumber = flightNumberController.text;
        String date = dateController.text;

        ChecklistDto checklistDto = ChecklistDto(
          inspectingStaff: username,
          stationName: stationName,
          flightNumber: flightNumber,
          date: date,
          items: [],
          timestamp: DateTime.now(),
        );

        int checklistId = await apiService.createChecklist(
          checklistDto,
          inspectingStaff: username,
          flightNumber: flightNumber,
          stationName: stationName,
          date: date,
        );

        Get.to(() => PreflightArrivals(
              stationName: stationName,
              flightNumber: flightNumber,
              date: date,
              checklistId: checklistId,
            ));
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to save data to the server',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?)? validator,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fieldWidth = screenWidth * 0.8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Container(
        width: fieldWidth,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 212, 211, 211),
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 20),
            hintText: hintText,
            border: InputBorder.none,
          ),
          validator: validator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.account_circle,
            color: Colors.white,
            size: 40,
          ),
          onPressed: _showUserDetails,
        ),
        actions: [
          PopupMenuButton<String>(
            iconColor: Colors.white,
            color: Colors.white,
            iconSize: 30,
            onSelected: (String result) async {
              switch (result) {
                case 'History':
                  Get.to(() => HistoryPage());
                  break;
                case 'Notices':
                  Get.to(() => NoticesPage());
                  break;
                case 'Logout':
                  await _authService.logout();

                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
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
              PopupMenuItem<String>(
                value: 'Logout',
                child:
                    Text('Log Out', style: GoogleFonts.openSans(fontSize: 14)),
              ),
            ],
          ),
        ],
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 82, 138, 41),
        title: Text(
          'ET Ground Safety Checklist',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.w600,
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Image.asset(
                    'images/finalLogo2.png',
                    width: 400,
                    height: 250,
                  )),
                  SizedBox(height: 10),
                  _buildDropdownField(),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: flightNumberController,
                    hintText: 'Flight Number',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the flight number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 212, 211, 211),
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: dateController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 20),
                              hintText: 'Flight Date',
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select the flight date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.625,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _saveToAPI,
                          child: _isSubmitting
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Checklist',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 82, 138, 41),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          double fieldWidth = screenWidth * 0.8;
          List<String> sortedStationNames = List.from(stationNames)..sort((a, b) => a.compareTo(b));
          return Container(
            width: fieldWidth,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 212, 211, 211),
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButtonFormField<String>(
              menuMaxHeight: MediaQuery.of(context).size.height * 0.3,
              value: selectedStation,
              hint: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Station Name'),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedStation = newValue!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a station name';
                }
                return null;
              },
              items:
                  sortedStationNames.map<DropdownMenuItem<String>>((String station) {
                return DropdownMenuItem<String>(
                  value: station,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(station),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showUserDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'User Details',
            style: TextStyle(color: const Color.fromARGB(255, 82, 138, 41)),
          ),
          content: Container(
            constraints: BoxConstraints(
              maxWidth: 300,
            ),
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 16.0,
              runSpacing: 8.0,
              children: [
                Row(
                  children: [
                    Text('Username: ',
                        style: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(username ?? 'N/A'),
                  ],
                ),
                Row(
                  children: [
                    Text('Email: ',
                        style: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(email ?? 'N/A'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Close',
                style: TextStyle(color: const Color.fromARGB(255, 82, 138, 41)),
              ),
            ),
          ],
        );
      },
    );
  }
}

