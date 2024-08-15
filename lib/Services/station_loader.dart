import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart'; // <-- Make sure this import is here
import 'package:csv/csv.dart';

Future<List<String>> loadStationNames() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;

  String filePath = '$appDocPath/Stations.csv';

  File csvFile = File(filePath);
  if (!csvFile.existsSync()) {
    ByteData data = await rootBundle.load('assets/Stations.csv');
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(filePath).writeAsBytes(bytes);
  }

  String csvContent = await csvFile.readAsString();

  List<List<dynamic>> rows = const CsvToListConverter().convert(csvContent);

  List<String> stationNames = rows.map((row) => row[0].toString()).toList();

  return stationNames;
}
