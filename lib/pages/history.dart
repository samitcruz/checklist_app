import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safety_check/pages/checklist_popup.dart';
import 'package:safety_check/Services/api_service.dart';
import 'package:safety_check/models/checklist.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TextEditingController searchController = TextEditingController();
  String searchString = "";
  List<Checklist> checklistData = [];
  ApiService apiService = ApiService();
  bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    fetchChecklists();
  }

  Future<void> fetchChecklists() async {
    try {
      List<Checklist> data = await apiService.getChecklistsByInspectingStaff();
      setState(() {
        checklistData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        Get.snackbar('Error', 'Failed to load Checklists',
            backgroundColor: Colors.red, colorText: Colors.white);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;

    List<Checklist> filteredData = checklistData.where((data) {
      String inspectingStaff = (data.inspectingStaff ?? '').toLowerCase();
      String station = data.stationName.toLowerCase();
      String flightNumber = data.flightNumber.toLowerCase();
      String date = data.date.toLowerCase();

      return inspectingStaff.contains(searchString) ||
          station.contains(searchString) ||
          flightNumber.contains(searchString) ||
          date.contains(searchString);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'History',
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              textStyle: TextStyle(color: Colors.white)),
        ),
        backgroundColor: const Color.fromARGB(255, 82, 138, 41),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search",
                hintText: "Enter Station Name, Flight Number or Date",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchString = value.toLowerCase().trim();
                });
              },
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 82, 138, 41),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        var data = filteredData[index];
                        String? inspector = data.inspectingStaff;
                        String station = data.stationName;
                        String flightNumber = data.flightNumber;
                        String date = data.date;

                        return ListTile(
                          title: Text(
                            "$station - $flightNumber - $date",
                            style: GoogleFonts.openSans(),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Inspection Officer: $inspector"),
                              Text("Station: $station"),
                              Text("Flight Number: $flightNumber"),
                              Text("Date: $date"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => ChecklistPopupPage(
                                  checklistId: data.id,
                                  station: station,
                                  flightNumber: flightNumber,
                                  date: date,
                                ));
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: const Color.fromARGB(255, 82, 138, 41),
                          thickness: 2,
                          indent: 16,
                          endIndent: 16,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
