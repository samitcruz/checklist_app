import 'package:flutter/material.dart';
import '../checklist_page.dart';
import '../main_page.dart';

class ReadyForDeparture extends StatelessWidget {
  final String stationName;
  final String flightNumber;
  final String date;

  ReadyForDeparture({
    required this.stationName,
    required this.flightNumber,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    return ChecklistPage(
      title: 'Ready for Departure',
      items: [
        '1. All equipment are removed',
        '2. All doors are closed',
        '3. No damage to the aircraft witnessed',
        '4. Area is cleared off FOD and equipment',
        '5. Safety cones and chocks removed',
        '6. Pushback assistant (Headset Man) takes over',
        '7. Watch blast area clearance',
        '8. Wing Walkers available?',
        '9. No equipment moves around & behind the aircraft while on push back ',
      ],
      nextPage: MainPage(),
      stationName: stationName,
      flightNumber: flightNumber,
      date: date,
      isLastPage: true,
    );
  }
}
