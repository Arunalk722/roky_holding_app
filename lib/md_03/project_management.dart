import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:roky_holding/env/DialogBoxs.dart';
import 'package:roky_holding/env/user_data.dart';
import '../env/api_info.dart';
import '../env/app_bar.dart';
import '../env/input_widget.dart';
import '../env/print_debug.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() =>
      _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _txtTenderController = TextEditingController();
  final _txtProjectNameController = TextEditingController();
  final _txtCivilWorkCostController = TextEditingController();
  final _txtMaterialCostController = TextEditingController();
  final _txtAllocatedCostController = TextEditingController();
  final _txtTenderCostController = TextEditingController();
  final _txtProjectIdCostController = TextEditingController();
  late bool _isActive = false;
  late bool _userVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveProjects();
    });
  }

  List<dynamic> _activeProjects = [];
  bool _isLoadingProjects = false;

  Future<void> _loadActiveProjects() async {
    setState(() {
      _isLoadingProjects = true;
    });

    try {
      // ✅ Show the Wait Dialog AFTER the first frame is built
      WaitDialog.showWaitDialog(context, message: 'Loading project');

      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        return;
      }

      String reqUrl = '${APIHost().APIURL}/project_management.php/listAll';
      final response = await http.post(
        Uri.parse(reqUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"Authorization": token}),
      );

      PD.pd(text: reqUrl);

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 200) {
            setState(() {
              clearText();
              _activeProjects = responseData['data'] ?? [];
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
        } catch (e) {
          PD.pd(text: e.toString());
        }
      } else {
        PD.pd(text: "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      PD.pd(text: e.toString());
    } finally {
      setState(() {
        _isLoadingProjects = false;
      });

      // ✅ Close the WaitDialog safely (only if it's still open)
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appname: 'Project Management'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600; // Check screen width

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: isWideScreen
                ? Row(
                    // Two columns if screen is wide
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildCreateProjectForm()),
                      const SizedBox(width: 20), // Spacing between columns
                      Expanded(child: _buildActiveProjectsListCard()),
                    ],
                  )
                : Column(
                    // Stack in a single column if screen is narrow
                    children: [
                      _buildCreateProjectForm(),
                      const SizedBox(height: 20), // Spacing between sections
                      _buildActiveProjectsListCard(),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCreateProjectForm() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: 400, // Keep max width limited
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Center(
                    child: Text(
                      'Create Project',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 20,
                  runSpacing: 15,
                  children: [
                    buildTextField(_txtProjectIdCostController, 'Project ID',
                        'Project ID', Icons.key, false, 10),
                    buildTextField(_txtTenderController, 'Tender',
                        'Enter tender number', Icons.receipt_long, true, 20),
                    buildTextField(_txtProjectNameController, 'Project Name',
                        'Enter project name', Icons.business, true, 45),
                    buildNumberField(
                        _txtCivilWorkCostController,
                        'Civil Work Cost',
                        'Enter cost',
                        Icons.engineering,
                        true,
                        10),
                    buildNumberField(
                        _txtMaterialCostController,
                        'Material Cost',
                        'Enter cost',
                        Icons.shopping_cart,
                        true,
                        10),
                    buildNumberField(
                        _txtAllocatedCostController,
                        'Allocated Cost',
                        'Enter cost',
                        Icons.monetization_on,
                        true,
                        10),
                    buildNumberField(_txtTenderCostController, 'Tender Cost',
                        'Enter cost', Icons.attach_money, true, 10),
                    _buildCheckboxes(),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: _isActive,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isActive = newValue ?? false;
                  });
                },
                activeColor: Colors.blueAccent,
              ),
              const Text('Is Active'),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: _userVisible,
                onChanged: (bool? newValue) {
                  setState(() {
                    _userVisible = newValue ?? false;
                  });
                },
                activeColor: Colors.blueAccent,
              ),
              const Text('User Visibility'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          PD.pd(text: "Form is valid!");
          YNDialogCon.ynDialogMessage(
            context,
            messageBody: 'Confirm to create a new project',
            messageTitle: 'Project Creating',
            icon: Icons.verified_outlined,
            iconColor: Colors.black,
            btnDone: 'YES',
            btnClose: 'NO',
          ).then((value) async {
            if (value == 1) {
              await createProjectManagement(context);
            }
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Background color
        foregroundColor: Colors.white, // Text color
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500, // Font weight
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5, // Elevation
        shadowColor: Colors.black26, // Shadow color
      ),
      child: const Text('Create Project'),
    );
  }

  Widget _buildActiveProjectsListCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Active Projects",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildActiveProjectsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProjectsList() {
    if (_isLoadingProjects) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeProjects.isEmpty) {
      return const Center(child: Text('No active projects found.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activeProjects.length,
      itemBuilder: (context, index) {
        final project = _activeProjects[index];
        return Card(
          // ... (card styling)
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.business, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project['project_name'] ?? 'Project Name',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tender: ${project['tender'] ?? 'Tender Number'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        // Add more details here if needed
                      ],
                    ),
                  ),
                  // View Button
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _isActive = project['is_active'] == '0'
                          ? false
                          : true; // Handle null case
                      _userVisible = project['user_visible'] == '0'
                          ? false
                          : true; // Handle null case
                      _txtTenderController.text =
                          project['tender'] ?? ''; // Update text field
                      _txtProjectNameController.text =
                          project['project_name'] ?? '';
                      _txtCivilWorkCostController.text =
                          project['exp_cost_civil_work']?.toString() ?? '';
                      _txtMaterialCostController.text =
                          project['exp_cost_material']?.toString() ?? '';
                      _txtAllocatedCostController.text =
                          project['exp_allocated_cost']?.toString() ?? '';
                      _txtTenderCostController.text =
                          project['tender_cost']?.toString() ?? '';
                      setState(() {});
                      PD.pd(text: "View project: ${project['tender']}");
                    },
                  ),
                  IconButton(
                    icon: Icon(project['user_visible'] as int == 1
                        ? Icons.visibility_off_outlined
                        : Icons.visibility),
                    color: project['user_visible'] as int == 1
                        ? Colors.blue
                        : Colors.red,
                    onPressed: () async {
                      int vis = project['user_visible'] as int;
                      String mg =
                          vis == 0 ? 'visibility enable' : 'visibility disable';
                      int result = await YNDialogCon.ynDialogMessage(
                        context,
                        messageTitle: mg,
                        messageBody:
                            "Are you sure you want to $mg project ${project['tender']}?",
                        icon: vis == 0
                            ? Icons.visibility
                            : Icons.visibility_off_outlined,
                        iconColor: Colors.orange,
                        btnDone: vis == 0 ? "Yes, Visible" : "Yes, Invisible",
                        btnClose: "Cancel",
                      );
                      if (result == 1) {
                        _changeVisibility(
                            context,
                            '${project['idtbl_projects']}',
                            project['user_visible'] == '0' ? false : true);
                      }
                    },
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red), // Red color for delete action
                    onPressed: () async {
                      int result = await YNDialogCon.ynDialogMessage(
                        context,
                        messageTitle: "Confirm Deletion",
                        messageBody:
                            "Are you sure you want to delete project ${project['tender']}?",
                        icon: Icons.warning,
                        iconColor: Colors.orange,
                        btnDone: "Yes, Delete",
                        btnClose: "Cancel",
                      );

                      if (result == 1) {
                        PD.pd(
                            text:
                                "Deleting project: ${project['idtbl_projects']}");
                        _deleteProject(context,
                            '${project['idtbl_projects']}'); // Call delete function after confirmation
                      }
                    },
                  ),

                  // const Icon(Icons.arrow_forward_ios, size: 16), // Optional arrow
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //create project
  Future<void> createProjectManagement(BuildContext context) async {
    // Add BuildContext
    try {
      WaitDialog.showWaitDialog(context, message: 'project creating');
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

      PD.pd(text: "Token: $token");
      String a = '${APIHost().APIURL}/project_management.php/create';
      final response = await http.post(
        Uri.parse(a),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": APIToken().token,
          "tender": _txtTenderController.text,
          "project_name": _txtProjectNameController.text,
          "exp_cost_civil_work": 1,
          "exp_cost_material": 1,
          "exp_allocated_cost": 1,
          "tender_cost": _txtTenderCostController.text,
          "created_by": UserCredentials().UserName,
          "change_by": UserCredentials().UserName,
          "is_active": _isActive,
          "user_visible": _userVisible,
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
            OneBtnDialog.oneButtonDialog(context,
                title: "Successful",
                message: responseData['message'],
                btnName: 'Ok',
                icon: Icons.verified_outlined,
                iconColor: Colors.black,
                btnColor: Colors.green);
            _loadActiveProjects();
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
        } catch (e) {
          PD.pd(
              text: "Error decoding JSON: $e, Body: ${response.body}"); // Debug
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
        String errorMessage =
            'Project Management failed with status code ${response.statusCode}';
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

  //delete project
  Future<void> _deleteProject(BuildContext context, String projectId) async {
    // Add BuildContext
    try {
      WaitDialog.showWaitDialog(context, message: 'Delete Project $projectId');
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

      PD.pd(text: "Token: $token");
      String a = '${APIHost().APIURL}/project_management.php/delete';
      final response = await http.post(
        Uri.parse(a),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": APIToken().token,
          "idtbl_projects": projectId,
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
            OneBtnDialog.oneButtonDialog(context,
                title: "Successful",
                message: responseData['message'],
                btnName: 'Ok',
                icon: Icons.verified_outlined,
                iconColor: Colors.black,
                btnColor: Colors.green);
            _loadActiveProjects();
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
        } catch (e) {
          PD.pd(
              text: "Error decoding JSON: $e, Body: ${response.body}"); // Debug
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
        String errorMessage =
            'Project Management failed with status code ${response.statusCode}';
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

  //change visibility
  Future<void> _changeVisibility(
      BuildContext context, String projectId, bool vis) async {
    // Add BuildContext
    try {
      WaitDialog.showWaitDialog(context,
          message: 'Change Project $projectId visibility');
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

      PD.pd(text: "Token: $token");
      String a = '${APIHost().APIURL}/project_management.php/changeVisibility';
      final response = await http.post(
        Uri.parse(a),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": APIToken().token,
          "idtbl_projects": projectId,
          "user_visible": 0,
          "change_by": UserCredentials().UserName
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
            OneBtnDialog.oneButtonDialog(context,
                title: "Successful",
                message: responseData['message'],
                btnName: 'Ok',
                icon: Icons.verified_outlined,
                iconColor: Colors.black,
                btnColor: Colors.green);
            _loadActiveProjects();
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
        } catch (e) {
          PD.pd(
              text: "Error decoding JSON: $e, Body: ${response.body}"); // Debug
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
        String errorMessage =
            'Project Management failed with status code ${response.statusCode}';
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

  void clearText() {
    _txtTenderController.text = "";
    _txtProjectNameController.text = "";
    _txtCivilWorkCostController.text = "";
    _txtMaterialCostController.text = "";
    _txtAllocatedCostController.text = "";
    _txtTenderCostController.text = "";
    _txtProjectIdCostController.text = "";
    _isActive = false;
  }
}
