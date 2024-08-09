import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NoticesPage extends StatelessWidget {
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
          backgroundColor: const Color.fromARGB(255, 82, 138, 41),
          title: Text('Notices',
              style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.white),
                  fontSize: fontSize))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Any discrepancy on the above checklist shall be reported to the handling agent Safety section with the airport safety office and be followed up until closure. If not, additional follow-up will continue from Customer Service QMS & SMS section.',
              style: GoogleFonts.openSans(fontSize: 17),
            ),
            SizedBox(height: 16),
            Text(
              '2. Always respect and follow the local regulation for safety.',
              style: GoogleFonts.openSans(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
