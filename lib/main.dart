import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:safety_check/Controllers/auth_controller.dart';
import 'package:safety_check/Controllers/checklist_controller.dart';
import 'package:safety_check/Services/secure_storage.dart';
import 'package:safety_check/pages/login_page.dart';
import 'package:safety_check/pages/main_page.dart';

Future<void> main() async {
  Get.put(AuthController());
  Get.put(ChecklistController());
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  try {
    await dotenv.load(fileName: "environment_variables.env");
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Error loading .env file: $e');
  }
  await storeClientCredentials();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
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
      home: Obx(
        () {
          final AuthController controller = Get.find();
          return controller.isAuthenticated ? MainPage() : LoginPage();
        },
      ),
    );
  }
}
