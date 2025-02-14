import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:roky_holding/md_01/login.dart';
import '../env/DialogBoxs.dart';
import '../env/api_info.dart';
import '../env/print_debug.dart';
import '../env/text_input_object.dart';
import 'package:http/http.dart' as http;
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  bool isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return emailRegExp.hasMatch(email);
  }
  Future<void> createUseers() async {
    final response = await http.post(
      Uri.parse('${APIHost().APIURL}/user_controller.php/create'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": _userName.text,
        "password": _password.text,
        "email":_email.text,
        "phoneNumber":_phone.text
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String message = responseData['message'];
      final int status = responseData['status'];
      if(status==200){
        PD.pd(text:message.toString());
        OneBtnDialog.oneButtonDialog(context, title: 'User Registration', message: responseData['message'], btnName: 'OK', icon: Icons.verified, iconColor: Colors.green, btnColor: Colors.black);
      }else{
        PD.pd(text:message);
        OneBtnDialog.oneButtonDialog(context, title: 'User Registration', message: responseData['message'], btnName: 'OK', icon: Icons.error, iconColor: Colors.red, btnColor: Colors.black);
      }

    } else {
      print('Failed to create user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column( // Use a Column for the main layout
        children: [
          Expanded( // Use Expanded to fill available space for the form
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
                        TextField(
                          controller: _userName,
                          maxLength: 45,
                          decoration: InputTextDecoration.inputDecoration(
                            lable_Text: 'User Name',
                            hint_Text: "Enter your user name",
                            icons: Icons.person,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _email,
                          maxLength: 45,
                          decoration: InputTextDecoration.inputDecoration(
                            lable_Text: 'Email',
                            hint_Text: "Enter your email",
                            icons: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _phone,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          decoration: InputTextDecoration.inputDecoration(
                            lable_Text: 'Phone Number',
                            hint_Text: "077XXXXXXX",
                            icons: Icons.phone,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _password,
                          maxLength: 20,
                          obscureText: true,
                          decoration: InputTextDecoration.inputDecoration(
                            lable_Text: 'Password',
                            hint_Text: 'Enter your password',
                            icons: Icons.password_rounded,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _confirmPassword,
                          maxLength: 20,
                          obscureText: true,
                          decoration: InputTextDecoration.inputDecoration(
                            lable_Text: 'Confirm Password',
                            hint_Text: 'Confirm your password',
                            icons: Icons.password_rounded,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {

                            if (_userName.text.length < 5) {
                              PD.pd(text: 'user name');
                              OneBtnDialog.oneButtonDialog(
                                context,
                                title: 'User Registration',
                                message: 'Please validate user name (at least 5 characters)',
                                btnName: 'OK',
                                icon: Icons.error,
                                iconColor: Colors.red,
                                btnColor: Colors.black,
                              );
                            } else if (!isValidEmail(_email.text)) {
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
                            } else if (_phone.text.length < 10) {
                              PD.pd(text: 'phone number');
                              OneBtnDialog.oneButtonDialog(
                                context,
                                title: 'User Registration',
                                message: 'Please enter a valid phone number (at least 10 digits)',
                                btnName: 'OK',
                                icon: Icons.error,
                                iconColor: Colors.red,
                                btnColor: Colors.black,
                              );
                            } else if (_password.text != _confirmPassword.text) {
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
                            } else if (_password.text.length < 5) { // Password length check
                              PD.pd(text: 'password too short');
                              OneBtnDialog.oneButtonDialog(
                                context,
                                title: 'User Registration',
                                message: 'Password must be at least 5 characters long',
                                btnName: 'OK',
                                icon: Icons.error,
                                iconColor: Colors.red,
                                btnColor: Colors.black,
                              );
                            } else {
                              createUseers();
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
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginApp()));
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