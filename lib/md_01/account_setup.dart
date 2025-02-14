import 'package:flutter/material.dart';
import 'package:roky_holding/env/api_info.dart';
import 'package:roky_holding/env/app_bar.dart';
import '../env/text_input_object.dart'; // Import your InputTextDecoration

class AccountSetupPage extends StatefulWidget {
  const AccountSetupPage({super.key});

  @override
  State<AccountSetupPage> createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  final TextEditingController _displayName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

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
                  const SizedBox(height: 20),
                  TextField(
                    controller: _displayName,
                    decoration: InputTextDecoration.inputDecoration(
                      lable_Text: 'Display Name',
                      hint_Text: "Enter your display name",
                      icons: Icons.person,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _email,
                    decoration: InputTextDecoration.inputDecoration(
                      lable_Text: 'Email',
                      hint_Text: "Enter your email",
                      icons: Icons.email_outlined,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _password,
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
                    obscureText: true,
                    decoration: InputTextDecoration.inputDecoration(
                      lable_Text: 'Confirm Password',
                      hint_Text: 'Confirm your password',
                      icons: Icons.password_rounded,
                    ),
                  ),

                  const SizedBox(height: 15),
                /*  ElevatedButton(
                    onPressed: () {
                      // Implement profile picture upload
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
                        Icon(Icons.image, color: Colors.white), // Add an Icon
                        SizedBox(width: 8), // Add some spacing
                        Text(
                          "Upload Profile Picture (Optional)",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),*/

                  ElevatedButton(
                    onPressed: () {

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