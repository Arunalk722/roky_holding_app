import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:roky_holding/env/api_info.dart';
import 'package:roky_holding/env/app_bar.dart';
import 'package:roky_holding/env/user_data.dart';
import '../env/DialogBoxs.dart';
import '../env/input_widget.dart';
import '../env/print_debug.dart';


class AccountSetupPage extends StatefulWidget {
  const AccountSetupPage({super.key});

  @override
  State<AccountSetupPage> createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  final TextEditingController _displayName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _currentPassword = TextEditingController();

  bool _isUserFound = false;

  @override
  void initState(){
    super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUserInfo();
      });
  }
  Future<void> _loadUserInfo() async {
    setState(() {
      _isUserFound = true;
    });

    try {
      WaitDialog.showWaitDialog(context, message: 'Loading user information');

      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        return;
      }

      String reqUrl = '${APIHost().APIURL}/user_controller.php/GetUserInfo';  // Your API endpoint
      final response = await http.post(
        Uri.parse(reqUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"Authorization": token,
          "username":UserCredentials().UserName}),
      );

      PD.pd(text: reqUrl);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 200) {
          // Successfully fetched user info, update the TextEditingController values
          setState(() {
            var userData = responseData['data'];
            _displayName.text = userData['display_name'] ?? '';
            _email.text = userData['email'] ?? '';
            _phoneNumber.text = userData['phone'] ?? '';
          });
        } else {
          final String message = responseData['message'] ?? 'Error';
          PD.pd(text: message);
          OneBtnDialog.oneButtonDialog(
            context,
            title: 'Error',
            message: message,
            btnName: 'OK',
            icon: Icons.error,
            iconColor: Colors.red,
            btnColor: Colors.black,
          );
        }
      } else {
        PD.pd(text: "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      PD.pd(text: e.toString());
    } finally {
      setState(() {
        _isUserFound = false;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }


  Future<void> updateProfile(BuildContext context) async {
    try {
      WaitDialog.showWaitDialog(context, message: 'Updating profile...');
      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        PD.pd(text: "Authentication token is missing.");
        ExceptionDialog.exceptionDialog(
          context,
          title: 'Authentication Error',
          message: "Authentication token is missing.",
          btnName: 'OK',
          icon: Icons.error,
          iconColor: Colors.red,
          btnColor: Colors.black,
        );
        return;
      }

      String url = '${APIHost().APIURL}/user_controller.php/ProfileUpdate';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": token,
          "username": UserCredentials().UserName,
          "email": _email.text,
          "phoneNumber": _phoneNumber.text,
          "display_name": _displayName.text,
        }),
      );

      PD.pd(text: "Response: \${response.statusCode} - \${response.body}");
      if (response.statusCode == 200) {
        WaitDialog.hideDialog(context);
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final int status = responseData['status'];

          if (status == 200) {
            PD.pd(text: responseData.toString());
            OneBtnDialog.oneButtonDialog(
              context,
              title: "Update Successful",
              message: responseData['message'],
              btnName: 'OK',
              icon: Icons.check_circle,
              iconColor: Colors.green,
              btnColor: Colors.black,
            );
          } else {
            final String message = responseData['message'] ?? 'Error updating profile';
            PD.pd(text: message);
            OneBtnDialog.oneButtonDialog(
              context,
              title: 'Update Failed',
              message: message,
              btnName: 'OK',
              icon: Icons.error,
              iconColor: Colors.red,
              btnColor: Colors.black,
            );
          }
        } catch (e) {
          PD.pd(text: "Error decoding JSON: \$e, Body: \${response.body}");
          ExceptionDialog.exceptionDialog(
            context,
            title: 'JSON Error',
            message: "Error decoding JSON response: \$e",
            btnName: 'OK',
            icon: Icons.error,
            iconColor: Colors.red,
            btnColor: Colors.black,
          );
        }
      } else {
        WaitDialog.hideDialog(context);
        String errorMessage =
            'Profile update failed with status code \${response.statusCode}';
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
      String errorMessage = 'An error occurred: \$e';
      if (e is FormatException) {
        errorMessage = 'Invalid JSON response';
      } else if (e is SocketException) {
        errorMessage = 'Network error. Please check your connection.';
      }
      WaitDialog.hideDialog(context);
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

  Future<void> changePassword(BuildContext context) async {
    try {
      WaitDialog.showWaitDialog(context, message: 'Changing password...');

      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        PD.pd(text: "Authentication token is missing.");
        ExceptionDialog.exceptionDialog(
          context,
          title: 'Authentication Error',
          message: "Authentication token is missing.",
          btnName: 'OK',
          icon: Icons.error,
          iconColor: Colors.red,
          btnColor: Colors.black,
        );
        return;
      }

      String url = '${APIHost().APIURL}/user_controller.php/ChangePassword';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": token,
          "username": UserCredentials().UserName,
          "current_password": _currentPassword.text,
          "new_password": _password.text,
        }),
      );

      PD.pd(text: "Response: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200) {
        WaitDialog.hideDialog(context);
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final int status = responseData['status'];

          if (status == 200) {
            PD.pd(text: responseData.toString());
            OneBtnDialog.oneButtonDialog(
              context,
              title: "Password Change Successful",
              message: responseData['message'],
              btnName: 'OK',
              icon: Icons.check_circle,
              iconColor: Colors.green,
              btnColor: Colors.black,
            );
          } else {
            final String message = responseData['message'] ?? 'Error changing password';
            PD.pd(text: message);
            OneBtnDialog.oneButtonDialog(
              context,
              title: 'Password Change Failed',
              message: message,
              btnName: 'OK',
              icon: Icons.error,
              iconColor: Colors.red,
              btnColor: Colors.black,
            );
          }
        } catch (e) {
          PD.pd(text: "Error decoding JSON: $e, Body: ${response.body}");
          ExceptionDialog.exceptionDialog(
            context,
            title: 'JSON Error',
            message: "Error decoding JSON response: $e",
            btnName: 'OK',
            icon: Icons.error,
            iconColor: Colors.red,
            btnColor: Colors.black,
          );
        }
      } else {
        WaitDialog.hideDialog(context);
        String errorMessage = 'Password change failed with status code ${response.statusCode}';
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
      String errorMessage = 'An error occurred: $e';
      if (e is FormatException) {
        errorMessage = 'Invalid JSON response';
      } else if (e is SocketException) {
        errorMessage = 'Network error. Please check your connection.';
      }
      WaitDialog.hideDialog(context);
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


  bool isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return emailRegExp.hasMatch(email);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appname: 'Account setup'),

      body: SingleChildScrollView( // For scrollability
        padding: const EdgeInsets.all(24.0),
        child: Center(
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
                  Image.network(
                    '${APIHost().APIImage}/logo.png', // Replace with your image path
                    height: 80, // Adjust height as needed
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Set Up Your Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  buildTextField(_email, 'Display Name',
                      'Enter your display name', Icons.person, true, 45),
                  //const SizedBox(height: 15),
                  buildTextField(_phoneNumber, 'Phone Number',
                      'Enter your phone number', Icons.phone, true, 10),
                  buildTextField(_email, 'Email',
                      'Enter your email', Icons.key, true, 45),

                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      if(!isValidEmail(_email.text)){
                        OneBtnDialog.oneButtonDialog(
                          context,
                          title: 'Account Setup',
                          message: 'Please enter a valid email address',
                          btnName: 'OK',
                          icon: Icons.error,
                          iconColor: Colors.red,
                          btnColor: Colors.black,
                        );
                      }
                      else if(_phoneNumber.text.length<10){
                        OneBtnDialog.oneButtonDialog(
                          context,
                          title: 'Account Setup',
                          message: 'Please enter a valid phone number (at least 10 digits)',
                          btnName: 'OK',
                          icon: Icons.error,
                          iconColor: Colors.red,
                          btnColor: Colors.black,
                        );
                      }
                      else if(_displayName.text.length>5){
                        OneBtnDialog.oneButtonDialog(
                          context,
                          title: 'Account Setup',
                          message: 'Please validate display name',
                          btnName: 'OK',
                          icon: Icons.error,
                          iconColor: Colors.red,
                          btnColor: Colors.black,
                        );
                      }
                      else{
                        updateProfile(context);
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
                      "Save",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16,),
                  buildPwdTextField(_currentPassword, 'Current Password', 'Enter your current', Icons.password_rounded, true, 20),
                  buildPwdTextField(_password, 'Password', 'Enter your password', Icons.password_rounded, true, 20),

                  buildPwdTextField(_confirmPassword, 'Confirm Password', 'Confirm your password', Icons.password_rounded, true, 20),

                  ElevatedButton(
                    onPressed: () {
                      if(_password.text!=_confirmPassword.text){
                          OneBtnDialog.oneButtonDialog(
                          context,
                          title: 'Account Setup',
                          message: 'please validate your password',
                          btnName: 'OK',
                          icon: Icons.error,
                          iconColor: Colors.red,
                          btnColor: Colors.black,
                        );
                      }else{
                       changePassword(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Row( // Use a Row to align icon and text
                      mainAxisSize: MainAxisSize.min, // Make Row take only needed space
                      children: [
                        Icon(Icons.password_rounded, color: Colors.white), // Add an Icon
                        SizedBox(width: 8), // Add some spacing
                        Text(
                          "Change Password",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}


