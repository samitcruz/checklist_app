import 'package:flutter/material.dart';
import 'package:safety_check/pages/generic_pages/on_arrival_checks.dart';
import '../checklist_page.dart';

class PreflightArrivals extends StatelessWidget {
  final String stationName;
  final String flightNumber;
  final String date;

  PreflightArrivals({
    required this.stationName,
    required this.flightNumber,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return ChecklistPage(
      title: 'Preflight Arrivals',
      items: [
        '1. Lines on the ramp clearly visible',
        '2. Foreign Object Debris (FOD) & fuel and oil leakage signs Inspection Done',
        '3. Serviceable Equipment Ready Out of ERA',
        '4. Equipment have rubber bumpers at the tip that connects to the aircraft body',
        '5. Staff ready with PPE',
        '6. Marshialler/ADS ready for guide',
        '7. Ramp agent ready with incoming CPM',
      ],
      nextPage: OnArrivalChecks(
        stationName: stationName,
        flightNumber: flightNumber,
        date: flightNumber,
      ),
      stationName: stationName,
      flightNumber: flightNumber,
      date: date,
    );
  }
}
