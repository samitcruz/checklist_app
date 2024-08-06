import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safety_check/models/checklist_item.dart';
import 'package:safety_check/pages/Services/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    fetchChecklists();
  }

  Future<void> fetchChecklists() async {
    try {
      List<Checklist> data = await apiService.getChecklists();
      setState(() {
        checklistData = data;
      });
    } catch (e) {
      print('Failed to fetch checklists: $e');
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
        title: Text(
          'History',
          style: GoogleFonts.openSans(
              fontSize: fontSize, textStyle: TextStyle(color: Colors.white)),
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
              child: ListView.builder(
                itemCount: checklistData.length,
                itemBuilder: (context, index) {
                  var data = checklistData[index];
                  String station = data.stationName;
                  String flightNumber = data.flightNumber;
                  String date = data.date;

                  if (station.toLowerCase().contains(searchString) ||
                      flightNumber.toLowerCase().contains(searchString) ||
                      date.toLowerCase().contains(searchString)) {
                    return ListTile(
                      title: Text(
                        "$station - $flightNumber - $date",
                        style: GoogleFonts.openSans(),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Station: $station"),
                          Text("Flight Number: $flightNumber"),
                          Text("Date: $date"),
                        ],
                      ),
                      onTap: () {
                        // Navigate to ChecklistPopupPage with the selected data
                        Get.to(() => ChecklistPopupPage(
                              checklistId: data.id,
                              station: station,
                              flightNumber: flightNumber,
                              date: date,
                            ));
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable

class ChecklistPopupPage extends StatelessWidget {
  final int checklistId;
  final String station;
  final String flightNumber;
  final String date;

  ChecklistPopupPage({
    required this.checklistId,
    required this.station,
    required this.flightNumber,
    required this.date,
  });

  final ApiService apiService = ApiService();

  Future<List<ChecklistItem>> fetchChecklistItems() async {
    try {
      return await apiService.getChecklistItems(checklistId);
    } catch (e) {
      print('Failed to fetch checklist items: $e');
      return [];
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
        title: Text(
          'Checklist Details',
          style: GoogleFonts.openSans(
              fontSize: fontSize, textStyle: TextStyle(color: Colors.white)),
        ),
        backgroundColor: const Color.fromARGB(255, 82, 138, 41),
      ),
      body: FutureBuilder<List<ChecklistItem>>(
        future: fetchChecklistItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No checklist items found'));
          } else {
            List<ChecklistItem> checklistItems = snapshot.data!;
            return ListView.builder(
              itemCount: checklistItems.length,
              itemBuilder: (context, index) {
                ChecklistItem item = checklistItems[index];
                return ListTile(
                  title: Text(item.description),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yes: ${item.yes}'),
                      Text('No: ${item.no}'),
                      if (item.remarkText != null &&
                          item.remarkText!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Remark: ${item.remarkText}'),
                        ),
                      if (item.remarkImagePath != null &&
                          item.remarkImagePath!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.network(
                            item.remarkImagePath!,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              }
                            },
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return Center(
                                child: Text('Failed to load image'),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
