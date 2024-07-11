import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TextEditingController searchController = TextEditingController();
  String searchString = "";

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
              decoration: InputDecoration(
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
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collectionGroup('dates')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return const Text("Loading...");
                  var results = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>?;
                    if (data == null) return false;

                    String station = data.containsKey('station')
                        ? data['station'].toString().toLowerCase()
                        : "";
                    String flightNumber = data.containsKey('flightNumber')
                        ? data['flightNumber'].toString().toLowerCase()
                        : "";
                    String date = data.containsKey('date')
                        ? data['date'].toString().toLowerCase()
                        : "";

                    return station.contains(searchString) ||
                        flightNumber.contains(searchString) ||
                        date.contains(searchString);
                  }).toList();
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      var data = results[index].data() as Map<String, dynamic>?;

                      String station =
                          data != null && data.containsKey('station')
                              ? data['station']
                              : "N/A";
                      String flightNumber =
                          data != null && data.containsKey('flightNumber')
                              ? data['flightNumber']
                              : "N/A";
                      String date = data != null && data.containsKey('date')
                          ? data['date']
                          : "N/A";

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
                                station: station,
                                flightNumber: flightNumber,
                                date: date,
                              ));
                        },
                      );
                    },
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

class ChecklistPopupPage extends StatelessWidget {
  final String station;
  final String flightNumber;
  final String date;

  ChecklistPopupPage({
    required this.station,
    required this.flightNumber,
    required this.date,
  });

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
        title: Text('Details',
            style: GoogleFonts.openSans(
                fontSize: fontSize, textStyle: TextStyle(color: Colors.white))),
        backgroundColor: const Color.fromARGB(255, 82, 138, 41),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('inspections')
            .doc(station)
            .collection('flights')
            .doc(flightNumber)
            .collection('dates')
            .doc(date)
            .collection('checklist')
            .get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No checklist data found."));
          }

          List<Map<String, dynamic>> checklistItems =
              snapshot.data!.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();

          return ListView.builder(
            itemCount: checklistItems.length,
            itemBuilder: (context, index) {
              var item = checklistItems[index];
              return ListTile(
                title: Text(item['item'], style: GoogleFonts.openSans()),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Yes: ${item['Yes']}"),
                    Text("No: ${item['No']}"),
                    Text("Remark: ${item['Remark']}"),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
