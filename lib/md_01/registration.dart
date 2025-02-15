import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:roky_holding/env/input_widget.dart';
import 'package:roky_holding/md_01/login.dart';
import '../env/DialogBoxs.dart';
import '../env/api_info.dart';
import '../env/print_debug.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _txtUserName = TextEditingController();
  final TextEditingController _txtEmail = TextEditingController();
  final TextEditingController _txtPassword = TextEditingController();
  final TextEditingController _txtConfirmPassword = TextEditingController();
  final TextEditingController _txtPhone = TextEditingController();
  final TextEditingController _txtDisplayName = TextEditingController();
  bool isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return emailRegExp.hasMatch(email);
  }

  Future<void> createUser(BuildContext context) async {
    try {
      WaitDialog.showWaitDialog(context, message: 'Creating user...');

      final response = await http.post(
        Uri.parse('${APIHost().APIURL}/user_controller.php/create'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _txtUserName.text,
          "password": _txtPassword.text,
          "email": _txtEmail.text,
          "phoneNumber": _txtPhone.text,
          "display_name": _txtDisplayName.text
        }),
      );

      PD.pd(text: "Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String message = responseData['message'];
        final int status = responseData['status'];

        WaitDialog.hideDialog(context);

        if (status == 200) {
          PD.pd(text: "User created successfully: $message");
          OneBtnDialog.oneButtonDialog(
            context,
            title: 'Success',
            message: 'User has been created successfully.',
            btnName: 'OK',
            icon: Icons.verified,
            iconColor: Colors.green,
            btnColor: Colors.black,
          );
        } else {
          PD.pd(text: "User creation failed: $message");
          OneBtnDialog.oneButtonDialog(
            context,
            title: 'Registration Failed',
            message: message,
            btnName: 'OK',
            icon: Icons.error,
            iconColor: Colors.red,
            btnColor: Colors.black,
          );
        }
      } else {
        WaitDialog.hideDialog(context);
        String errorMessage = 'User registration failed with status code ${response.statusCode}';

        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (e) {
            errorMessage = response.body;
          }
        }

        PD.pd(text: errorMessage);
        ExceptionDialog.exceptionDialog(
          context,
          title: 'HTTP Error',
          message: errorMessage,
          btnName: 'OK',
          icon: Icons.error,
          iconColor: Colors.red,
          btnColor: Colors.black,
        );
      }
    } catch (e) {
      WaitDialog.hideDialog(context);
      String errorMessage = 'An error occurred: $e';

      if (e is FormatException) {
        errorMessage = 'Invalid JSON response.';
      } else if (e is SocketException) {
        errorMessage = 'Network error. Please check your connection.';
      }

      PD.pd(text: errorMessage);
      ExceptionDialog.exceptionDialog(
        context,
        title: 'General Error',
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
      body: Column(
        // Use a Column for the main layout
        children: [
          Expanded(
            // Use Expanded to fill available space for the form
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'images/logo.png', // Replace with your image path
                          height: 80,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        BuildTextField(_txtDisplayName, 'Display Name',
                            'Enter your Display name', Icons.person, true, 45),
                        BuildTextField(_txtUserName, 'User Name',
                            'Enter your user name', Icons.person, true, 20),
                        BuildTextField(_txtEmail, 'Email',
                            'Enter your email', Icons.email, true, 45),
                        BuildTextField(_txtPhone, 'Phone Number',
                            '077XXXXXXX', Icons.phone, true, 10),
                        BuildPwdTextField(_txtPassword, 'Password',
                            'Enter your password', Icons.password_rounded, true, 20),
                        BuildPwdTextField(_txtConfirmPassword, 'Confirm Password',
                            'Confirm your password', Icons.password_rounded, true, 20),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_txtUserName.text.length < 5) {
                              PD.pd(text: 'user name');
                              OneBtnDialog.oneButtonDialog(
                                context,
                                title: 'User Registration',
                                message:
                                    'Please validate user name (at least 5 characters)',
                                btnName: 'OK',
                                icon: Icons.error,
                                iconColor: Colors.red,
                                btnColor: Colors.black,
                              );
                            } else if (!isValidEmail(_txtEmail.text)) {
                              PD.pd(text: 'invalid email');
                              OneBtnDialog.oneButtonDialog(
                                context,
                                title: 'User Registration',
                                message: 'Please enter a valid email address',
                                btnName: 'OK',
                                icon: Icons.error,
                                iconColor: Colors.red,
                                btnColor: Colors.black,
                              );
                            } else if (_txtPhone.text.length < 10) {
                              PD.pd(text: 'phone number');
                              OneBtnDialog.oneButtonDialog(
                                context,
                                title: 'User Registration',
                                message:
                                    'Please enter a valid phone number (at least 10 digits)',
                                btnName: 'OK',
                                icon: Icons.error,
                                iconColor: Colors.red,
                                btnColor: Colors.black,
                              );
                            } else if (_txtPassword.text !=
                                _txtConfirmPassword.text) {
                              PD.pd(text: 'passwords do not match');
                              OneBtnDialog.oneButtonDialog(
                                context,
                                title: 'User Registration',
                                message: 'Passwords do not match',
                                btnName: 'OK',
                                icon: Icons.error,
                                iconColor: Colors.red,
                                btnColor: Colors.black,
                              );
                            } else if (_txtPassword.text.length < 5) {
                              // Password length check
                              PD.pd(text: 'password too short');
                              OneBtnDialog.oneButtonDialog(
                                context,
                                title: 'User Registration',
                                message:
                                    'Password must be at least 5 characters long',
                                btnName: 'OK',
                                icon: Icons.error,
                                iconColor: Colors.red,
                                btnColor: Colors.black,
                              );
                            } else {
                              createUser(context);
                            }
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
                            "Register",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginApp()));
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Footer Image
          SizedBox(
            height: 40,
            width: 40,
            child: Image.asset(
              'images/Hbiz.jpg',
              fit: BoxFit.cover, // or other BoxFit values
            ),
          )
        ],
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
