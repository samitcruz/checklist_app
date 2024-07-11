import 'package:flutter/material.dart';
import 'package:safety_check/pages/generic_pages/aircraft_fueling.dart';
import 'package:safety_check/pages/checklist_page.dart';

class OnArrivalChecks extends StatelessWidget {
  final String stationName;
  final String flightNumber;
  final String date;

  OnArrivalChecks({
    required this.stationName,
    required this.flightNumber,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    return ChecklistPage(
      title: 'On Arrival/During Operation Checks',
      items: [
        '1. No staff/Equipment approached before engine off, anti-collision beacon & aircraft is chocked on and marshaller gives clearance. ',
        '2. Aircraft parked at right spot',
        '3. Chocks placed per standard/aircraft type',
        '4. Safety Cones placed per standard',
        '5. Check for physical damage on Aircraft before any activity',
        '6. Twice brake checks made while equipment approaches aircraft',
        '7. Reasonable clearance is left between the aircraft and the equipment positioned',
        '8. Stabilizers are set for all equipment positioned to the aircraft ',
        '9. Check for any damage on the door area before opening cabin/cargo door',
        '10. Equipment are not operated under the aircraft wing. ',
      ],
      nextPage: AircraftFueling(
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
