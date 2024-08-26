import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:safety_check/Controllers/auth_controller.dart';
import 'package:safety_check/pages/main_page.dart';
import 'package:safety_check/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = Get.find();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    await Future.delayed(Duration(seconds: 3));

    if (_authController.isAuthenticated) {
      Get.off(() => MainPage());
    } else {
      Get.off(() => LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: buildUI(),
    );
  }

  Widget buildUI() {
    return Center(
      child: Lottie.asset("assets/animations/ChecklistPlain.json"),
    );
  }
}
