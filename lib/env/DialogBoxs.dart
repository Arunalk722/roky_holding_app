import 'dart:async';

import 'package:flutter/material.dart';

class YNDialogCon {
  static Future<int> ynDialogMessage(
      BuildContext context, {
        required String messageBody,
        required String messageTitle,
        required IconData icon,
        required Color iconColor,
        required String btnDone,
        required String btnClose,
      }) async {
    final completer = Completer<int>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // More rounded corners for modern look
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400, // Increase width for better look on larger screens
              maxHeight: 250, // Adequate space for the content
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0), // More padding for spacious look
              child: Column(
                mainAxisSize: MainAxisSize.min, // Keeps dialog compact
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: iconColor,
                        size: 40, // Slightly bigger icon for better visibility
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          messageTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20, // Increase size for better readability
                            color: Colors.black87, // Darker color for better contrast
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    messageBody,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          completer.complete(1); // Done action
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Spacious padding for better touch targets
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners for modern look
                          ),
                          elevation: 5, // Slight shadow for depth
                        ),
                        child: Text(
                          btnDone,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // Appropriate font size for buttons
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          completer.complete(0); // Close action
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5, // Slight shadow for depth
                        ),
                        child: Text(
                          btnClose,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return completer.future;
  }
}



class OneBtnDialog {
  static Future<bool> oneButtonDialog(
      BuildContext context, {
        required String title,
        required String message,
        required String btnName,
        required IconData icon,
        required Color iconColor,
        required Color btnColor,
      }) async {
    final Completer<bool> completer = Completer<bool>(); // Return a boolean

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners for modern appeal
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400, // Set width for the dialog box to make it smaller
              maxHeight: 250, // Set height to be more compact
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Spacious padding for content
              child: Column(
                mainAxisSize: MainAxisSize.min, // Keeps dialog compact
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: iconColor,
                        size: 40, // Icon size for better visibility
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20, // Larger font for the title
                            color: Colors.black87, // Darker text for better contrast
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 200, // Button width adjusted for smaller dialog
                      child: ElevatedButton(
                        onPressed: () {
                          completer.complete(true); // Complete with true (user pressed the button)
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnColor, // Button background color
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Spacious padding for button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners for the button
                          ),
                          elevation: 5, // Slight shadow for depth
                        ),
                        child: Text(
                          btnName,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return completer.future; // Return the Future<bool>
  }
}


class ExceptionDialog {
  static void exceptionDialog(
      BuildContext context, {
        required String title,
        required String message,
        required String btnName,
        required IconData icon,
        required Color iconColor,
        required Color btnColor,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;

            // Adjust sizes based on screen width and height
            double iconSize = screenWidth > 600 ? screenWidth * 0.08 : screenWidth * 0.12; // Smaller icon for web
            double titleFontSize = screenWidth > 600 ? screenWidth * 0.05 : screenWidth * 0.06; // Smaller title font on web
            double messageFontSize = screenWidth > 600 ? screenWidth * 0.035 : screenWidth * 0.04; // Smaller message font on web
            double buttonWidth = screenWidth > 600 ? screenWidth * 0.3 : screenWidth * 0.4; // Smaller button width on web
            double buttonPadding = screenWidth > 600 ? screenWidth * 0.05 : screenWidth * 0.06; // Smaller button padding on web

            return AlertDialog(
              backgroundColor: const Color(0xFFF5F5F5), // Light, clean background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Rounded corners for modern look
              ),
              titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
              contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
              title: Row(
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: iconSize, // Dynamic, responsive icon size
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: const Color(0xFF333333), // Dark text for readability
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: messageFontSize,
                    color: const Color(0xFF555555), // Slightly lighter for readability
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 20.0),
              actions: [
                Center(
                  child: SizedBox(
                    width: buttonWidth, // Responsive button width
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor, // Custom button color
                        textStyle: const TextStyle(
                          color: Colors.white, // White text on button
                          fontWeight: FontWeight.bold,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: buttonPadding,
                          vertical: 14, // Slightly taller button
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded button
                        ),
                        elevation: 4, // Subtle shadow for depth
                      ),
                      child: Text(
                        btnName,
                        style: TextStyle(fontSize: 16), // Ensure text is legible
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class WaitDialog {
  static void showWaitDialog(BuildContext context, {required String message}) {
    showDialog(
      barrierDismissible: false, // Prevent user from closing the dialog manually
      context: context,
      builder: (context) {
        return WillPopScope( // Ensures back button is disabled
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent, // Transparent background for glass effect
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 4,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Please wait...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void hideDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}