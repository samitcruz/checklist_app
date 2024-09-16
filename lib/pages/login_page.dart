import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safety_check/Services/authentication_service.dart';
import 'package:safety_check/Services/secure_storage.dart';
import 'package:safety_check/models/authentication.dart';
import 'package:safety_check/pages/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class SecureStorage {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Constants
  static const _failedAttemptKeyPrefix = 'failedAttempt_';
  static const _attemptCountKey = 'attemptCount';
  static const _lockoutEndTimeKey = 'lockoutEndTime';

  // Store a failed login attempt with a unique key
  Future<void> addFailedAttempt(DateTime attemptTime) async {
    final key = '$_failedAttemptKeyPrefix${attemptTime.millisecondsSinceEpoch}';
    await _storage.write(key: key, value: attemptTime.toIso8601String());

    // Increment the attempt count
    final currentCount = await getFailedAttemptsCount();
    await _storage.write(
        key: _attemptCountKey, value: (currentCount + 1).toString());
  }

  // Get the total number of failed attempts
  Future<int> getFailedAttemptsCount() async {
    final countString = await _storage.read(key: _attemptCountKey);
    return int.tryParse(countString ?? '0') ?? 0;
  }

  // Clear all failed attempts and reset the attempt count
  Future<void> clearFailedAttempts() async {
    final allKeys = await _storage.readAll();
    for (var key in allKeys.keys) {
      if (key.startsWith(_failedAttemptKeyPrefix)) {
        await _storage.delete(key: key);
      }
    }
    await _storage.delete(key: _attemptCountKey); // Reset the attempt count
  }

  // Set the lockout end time
  Future<void> setLockoutEndTime(DateTime endTime) async {
    await _storage.write(
        key: _lockoutEndTimeKey, value: endTime.toIso8601String());
  }

  // Get the lockout end time
  Future<DateTime?> getLockoutEndTime() async {
    final endTimeString = await _storage.read(key: _lockoutEndTimeKey);
    if (endTimeString != null) {
      return DateTime.parse(endTimeString);
    }
    return null;
  }

  // Clear the lockout end time
  Future<void> clearLockoutEndTime() async {
    await _storage.delete(key: _lockoutEndTimeKey);
  }
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthenticationService _authService = AuthenticationService();
  final SecureStorage _secureStorage = SecureStorage();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _isLockedOut = false;
  DateTime? _lockoutEndTime;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color.fromARGB(255, 82, 138, 41),
    ));
    _checkLockoutStatus();
  }

  Future<void> _checkLockoutStatus() async {
    print("Checking lockout status...");
    _lockoutEndTime = await _secureStorage.getLockoutEndTime();
    if (_lockoutEndTime != null && DateTime.now().isBefore(_lockoutEndTime!)) {
      print("User is locked out until $_lockoutEndTime");
      setState(() {
        _isLockedOut = true;
      });
      Future.delayed(_lockoutEndTime!.difference(DateTime.now()), () async {
        print("Lockout period ended");
        setState(() {
          _isLockedOut = false;
        });
        await _secureStorage.clearLockoutEndTime();
      });
    } else {
      print("User is not locked out");
    }
  }

  void _authenticateAndLogin() async {
    if (_isLockedOut) {
      print("User is currently locked out.");
      Get.snackbar(
        'Locked Out',
        'You are temporarily locked out. Please try again later.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      print("Authenticating client...");
      final credentials = await getClientCredentials();
      ClientAuthResponse? clientResponse =
          await _authService.authenticateClient(
        credentials['CLIENT_NAME']!,
        credentials['CLIENT_SECRET']!,
      );

      if (clientResponse != null) {
        print('Client authenticated successfully');

        User? user = await _authService.login(
            _usernameController.text.trim(), _passwordController.text.trim());

        if (user != null) {
          print('User logged in successfully');
          Get.offAll(() => MainPage());
        } else {
          print('User login failed');
          await _handleFailedAttempt();
        }
      } else {
        print('Client authentication failed');
        Get.snackbar(
          'Error',
          'Client authentication failed. Please check your credentials.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('An error occurred during authentication: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _handleFailedAttempt() async {
    print("Handling failed attempt...");
    final failedAttempts = await _secureStorage.getFailedAttemptsCount();

    if (failedAttempts >= 2) {
      print("User locked out due to too many failed attempts");
      final lockoutEndTime = DateTime.now().add(Duration(minutes: 5));
      await _secureStorage.setLockoutEndTime(lockoutEndTime);
      await _secureStorage.clearFailedAttempts(); // Clear old attempts
      setState(() {
        _isLockedOut = true;
      });
      Get.snackbar('Locked Out',
          'You have been locked out for 5 minutes due to multiple failed login attempts. You will be able to try again at ${lockoutEndTime.toLocal()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 7));
    } else {
      print("Incrementing failed attempts");
      await _secureStorage
          .addFailedAttempt(DateTime.now()); // Use addFailedAttempt method
      Get.snackbar(
        'Error',
        'Could not Login. Please Check Your Username and Password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: const Color.fromARGB(255, 82, 138, 41),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Image.asset(
                  'images/finalLogo2.png',
                  height: 250,
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          offset: Offset(4.0, 4.0),
                          blurRadius: 10.0,
                          spreadRadius: 1.0,
                        ),
                        BoxShadow(
                          color: Colors.grey.shade400,
                          offset: Offset(-4.0, -4.0),
                          blurRadius: 10.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome!',
                          style: GoogleFonts.openSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.person),
                                  border: InputBorder.none,
                                  hintText: 'Username',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.lock),
                                  border: InputBorder.none,
                                  hintText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Get.snackbar(
                                '',
                                '',
                                backgroundColor:
                                    Color.fromARGB(255, 217, 196, 0)
                                        .withOpacity(0.8),
                                colorText: Colors.white,
                                titleText: Text(
                                  'Support',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                messageText: Text(
                                  'Contact support team',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              overlayColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.pressed))
                                    return const Color.fromARGB(
                                            255, 76, 170, 80)
                                        .withOpacity(0.3);
                                  return null;
                                },
                              ),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.openSans(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSubmitting || _isLockedOut
                                ? null
                                : _authenticateAndLogin,
                            style: ButtonStyle(
                              elevation:
                                  WidgetStateProperty.all(0), // Removes shadow
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Color.fromARGB(255, 157, 157,
                                        157); // Color when disabled (locked out)
                                  }
                                  if (states.contains(WidgetState.pressed)) {
                                    return Colors.grey; // Color when pressed
                                  }
                                  return Color.fromARGB(
                                      255, 82, 138, 41); // Default color
                                },
                              ),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            child: Center(
                              child: _isSubmitting
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      _isLockedOut ? 'Locked Out' : 'Log In',
                                      style: GoogleFonts.openSans(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Image.asset(
                  'images/sash.png',
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
