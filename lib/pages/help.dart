import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.white), // Set the color of the back button
            onPressed: () {
              Get.back();
            },
          ),
          backgroundColor: const Color.fromARGB(255, 82, 138, 41),
          title: Text(
            'Help',
            style: GoogleFonts.openSans(
              textStyle: TextStyle(color: Colors.white),
              fontSize: fontSize,
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'This is a Place holder',
          style:
              GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
