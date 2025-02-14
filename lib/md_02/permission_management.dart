import 'package:flutter/material.dart';
import '../env/text_input_object.dart';

class PermissionManagementPage extends StatefulWidget {
  const PermissionManagementPage({super.key});

  @override
  State<PermissionManagementPage> createState() =>
      _PermissionManagementPageState();
}

class _PermissionManagementPageState extends State<PermissionManagementPage> {
  String? _selectedUser;
  double? _authorizedCreditLimit;

  final List<String> _users = ['User 1', 'User 2', 'User 3', 'User 4'];

  // Store checkbox values in a Map for better organization
  final Map<String, bool> _permissions = {
    'Allow to Authorize': false,
    'Allow to Approve': false,
    'Allow to Office Expenses': false,
    'Allow to Construction': false,
    'Allow to Project Management': false,
    'Allow to Material Management': false,
    'Allow to Estimation Creating': false,
    'Allow to Edit Construction Request': false,
    'Allow to Edit Office Request': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Permission Managements"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 30),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select User",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF673AB7)),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputTextDecoration.inputDecoration(
                      lable_Text: 'Select User',
                      hint_Text: "Select User",
                      icons: Icons.person,
                    ),
                    value: _selectedUser,
                    items: _users.map((user) {
                      return DropdownMenuItem<String>(
                        value: user,
                        child: Text(user),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUser = value;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // Authorization Permissions
                  _buildPermissionSection(
                      "Authorization Permissions",
                      [
                        "Allow to Authorize",
                        "Allow to Approve",
                      ],
                      "Authorized Credit Limit"),

                  const SizedBox(height: 10),

                  // Use Request Allowing Permissions
                  _buildPermissionSection("Requests Allowing", [
                    "Allow to Office Expenses",
                    "Allow to Construction",
                  ]),

                  const SizedBox(height: 10),

                  // Use Permission Allowing
                  _buildPermissionSection("Permission Allowing", [
                    "Allow to Project Management",
                    "Allow to Material Management",
                    "Allow to Estimation Creating",
                    "Allow to Edit Construction Request",
                    "Allow to Edit Office Request",
                  ]),

                  const SizedBox(height: 10),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Save permissions logic here
                        _savePermissions();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text("Save Permissions",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionSection(String title, List<String> permissions,
      [String? creditLimitLabel]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold, color: const Color(0xFF673AB7)),
        ),
        const SizedBox(height: 16),
        for (var permission in permissions)
          _buildPermissionRow(permission, _permissions[permission]!, (value) {
            setState(() {
              _permissions[permission] = value!;
            });
          }),
        if (creditLimitLabel != null)
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputTextDecoration.inputDecoration(
              lable_Text: creditLimitLabel,
              hint_Text: "Enter $creditLimitLabel",
              icons: Icons.monetization_on,
            ),
            onChanged: (value) {
              setState(() {
                _authorizedCreditLimit = double.tryParse(value);
              });
            },
          ),
      ],
    );
  }

  Widget _buildPermissionRow(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blueAccent,
        ),
        Text(label),
      ],
    );
  }

  void _savePermissions() {
    // Access the permission values like this:
    print("Selected User: $_selectedUser");
    print("Authorized Credit Limit: $_authorizedCreditLimit");
    _permissions.forEach((key, value) {
      print("$key: $value");
    });

    // ... your save logic here ...
  }
}
