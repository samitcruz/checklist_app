import 'package:flutter/material.dart';
import '../checklist_page.dart';
import 'ready_for_departure.dart';

class AircraftFueling extends StatelessWidget {
  final String stationName;
  final String flightNumber;
  final String date;

  AircraftFueling({
    required this.stationName,
    required this.flightNumber,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    return ChecklistPage(
      title: 'Aircraft Fueling Operation',
      items: [
        '1. Fire truck available if fueling is done while passengers are on board. ',
        '2. Crew informed when #1 is practiced.',
        '3. No movement is allowed between the fire truck and the fueling truck in case of #1 above.',
        '4. Other vehicle movement restricted around the fueling truck while refueling.',
      ],
      nextPage: ReadyForDeparture(
        stationName: stationName,
        flightNumber: flightNumber,
        date: date,
      ),
      stationName: stationName,
      flightNumber: flightNumber,
      date: date,
    );
  }
}
