import 'package:flutter/material.dart';
import 'package:safety_check/api_service.dart';
import 'package:safety_check/models/checklist_item.dart';

class OnArrivalChecks extends StatefulWidget {
  final String stationName;
  final String flightNumber;
  final String date;
  final int checklistId;

  OnArrivalChecks({
    required this.stationName,
    required this.flightNumber,
    required this.date,
    required this.checklistId,
  });

  @override
  _OnArrivalChecksState createState() => _OnArrivalChecksState();
}

class _OnArrivalChecksState extends State<OnArrivalChecks> {
  List<ChecklistItem> items = [];
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    items = [
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'No staff/Equipment approached before engine off, anti-collision beacon & aircraft is chocked on and marshaller gives clearance.',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Aircraft parked at right spot',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Chocks placed per standard/aircraft type',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'Twice brake checks made while equipment approaches aircraft',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'Reasonable clearance is left between the aircraft and the equipment positioned',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'Stabilizers are set for all equipment positioned to the aircrafte',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description:
              'Check for any damage on the door area before opening cabin/cargo door',
          yes: false,
          no: false),
      ChecklistItem(
          checklistId: widget.checklistId,
          description: 'Equipment are not operated under the aircraft wing.',
          yes: false,
          no: false),
    ];
  }

  void _saveChecklist() async {
    try {
      for (var item in items) {
        var createDto = item.toCreateDto();
        await apiService.createChecklistItem(widget.checklistId, createDto);
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checklist saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save checklist: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preflight Arrivals')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          ChecklistItem item = items[index];
          return ListTile(
            title: Text(item.description),
            subtitle: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: item.yes,
                        onChanged: (bool? value) {
                          setState(() {
                            item.yes = value ?? false;
                            if (item.yes)
                              item.no = false; // Ensure mutual exclusivity
                          });
                        },
                      ),
                      Text('Yes'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: item.no,
                        onChanged: (bool? value) {
                          setState(() {
                            item.no = value ?? false;
                            if (item.no)
                              item.yes = false; // Ensure mutual exclusivity
                          });
                        },
                      ),
                      Text('No'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveChecklist,
        child: Icon(Icons.save),
      ),
    );
  }
}
