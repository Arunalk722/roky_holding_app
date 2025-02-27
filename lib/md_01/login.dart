import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:roky_holding/env/api_info.dart';
import 'package:roky_holding/env/app_versions.dart';
import 'package:roky_holding/md_01/registration.dart';
import 'package:roky_holding/md_02/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../env/DialogBoxs.dart';
import '../env/input_widget.dart';
import '../env/print_debug.dart';
import '../env/user_data.dart';

class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  State<LoginApp> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _password = TextEditingController();
  @override
  void initState() {
    super.setState(() {
      // _userName.text = 'admin';
      // _password.text = '123Admin@';
     // PD.pd(text: logo);
    });
  }

 // final String logo = '${APIHost().APIImage}/logo.png';

  Future<void> loginSystem() async {
    WaitDialog.showWaitDialog(context, message: 'sign in');
    try {
      final response = await http.post(
        Uri.parse('${APIHost().APIURL}/login_controller.php/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"username": _userName.text, "password": _password.text}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final int status = responseData['status']; // Get status first

        if (status == 200) {
          UserCredentials().setUserData(
            responseData['user_name'],
            responseData['email'],
            responseData['phone'],
            responseData['idtbl_users'],
          );
          APIToken().token = responseData['token'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['token']);
          WaitDialog.hideDialog(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          final String message = responseData['message'] ??
              'Login failed'; // Provide a default message
          PD.pd(text: message);
          WaitDialog.hideDialog(context);
          OneBtnDialog.oneButtonDialog(
            context,
            title: 'Failed to login',
            message: message,
            btnName: 'OK',
            icon: Icons.error,
            iconColor: Colors.red,
            btnColor: Colors.black,
          );
        }
      } else {
        String errorMessage =
            'Login failed with status code ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ??
                errorMessage; // Extract error message if available
          } catch (e) {
            // If JSON decoding fails, use the raw body
            errorMessage = response.body;
          }
        }
        PD.pd(text: errorMessage);
        WaitDialog.hideDialog(context);
        ExceptionDialog.exceptionDialog(
          context,
          title: 'Failed to login',
          message: errorMessage,
          btnName: 'OK',
          icon: Icons.error,
          iconColor: Colors.red,
          btnColor: Colors.black,
        );
      }
    } catch (e) {
      // Catch network errors, JSON parsing errors, etc.
      String errorMessage = 'An error occurred during login: $e';
      if (e is FormatException) {
        errorMessage = 'Invalid JSON response';
      } else if (e is SocketException) {
        errorMessage = 'Network error. Please check your connection.';
      }

      PD.pd(text: errorMessage);
      WaitDialog.hideDialog(context);
      ExceptionDialog.exceptionDialog(
        context,
        title: 'Login Error',
        message: errorMessage,
        btnName: 'OK',
        icon: Icons.error,
        iconColor: Colors.red,
        btnColor: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              // Added padding inside the container
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Added Image at the top
                Image.network(
                'http://220.247.246.76:8002/RN/src/img/logo.png',
                height: 80,
                errorBuilder: (context, object, stackTrace) {
                  print('Image load failed: $object, Stack trace: $stackTrace');  // Print the error to the console
                  return const Icon(Icons.error); // Show an error icon
                },
              ),
                  const SizedBox(height: 20),
                  const Text(
                    "WELCOME TO THE",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const Text(
                    "ROKY HOLDINGS",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildTextField(_userName, 'User Name',
                      'Enter your user name', Icons.person, true, 20),
                  buildPwdTextField(_password, 'Password',
                      'Your password', Icons.password_rounded, true, 20),
                  ElevatedButton(
                    onPressed: () {
                      loginSystem();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    // Changed to TextButton for "Need help?"
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegistrationPage()));
                    },
                    child: const Text(
                      "Need help?",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  AppVersionTile()
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200], // Changed background color
    );
  }
}
