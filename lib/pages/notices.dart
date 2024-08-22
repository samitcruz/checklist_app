import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NoticesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.045;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: const Color.fromARGB(255, 82, 138, 41),
        title: Text(
          'Notices & Guidelines',
          style: GoogleFonts.openSans(
            textStyle: TextStyle(color: Colors.white),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNoticeItem(
                'Any discrepancy on the above checklist shall be reported to the handling agent Safety section with the airport safety office and be followed up until closure. If not, additional follow-up will continue from Customer Service QMS & SMS section.',
              ),
              SizedBox(height: 20),
              _buildNoticeItem(
                'Always respect and follow the local regulation for safety.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, color: Colors.green, size: 28),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.openSans(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
