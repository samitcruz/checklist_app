import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safety_check/models/checklist_item.dart';
import 'package:safety_check/Services/api_service.dart';

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
            return ListView.separated(
              itemCount: checklistItems.length,
              separatorBuilder: (context, index) {
                return Divider(
                  color: const Color.fromARGB(255, 82, 138, 41),
                  thickness: 2,
                  indent: 16,
                  endIndent: 16,
                );
              },
              itemBuilder: (context, index) {
                ChecklistItem item = checklistItems[index];
                return ListTile(
                  title: Text(item.description, style: GoogleFonts.openSans()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yes: ${item.yes}', style: GoogleFonts.openSans()),
                      Text('No: ${item.no}', style: GoogleFonts.openSans()),
                      if (item.remarkText != null &&
                          item.remarkText!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Remark: ${item.remarkText}',
                            style: GoogleFonts.openSans(),
                          ),
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
                                child: Text('Failed to load image',
                                    style: GoogleFonts.openSans()),
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
