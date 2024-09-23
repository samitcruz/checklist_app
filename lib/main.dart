import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:safety_check/Controllers/auth_controller.dart';
import 'package:safety_check/Controllers/checklist_controller.dart';
import 'package:safety_check/Services/secure_storage.dart';
import 'package:safety_check/pages/splash_screen.dart';

Future<void> main() async {
  Get.put(AuthController());
  Get.put(ChecklistController());
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "environment_variables.env");
  await storeClientCredentials();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Station Ground Inspection Checklist',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(),
    );
  }
}
