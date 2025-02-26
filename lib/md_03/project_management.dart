import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
  final _txtTender = TextEditingController();
  final _txtProjectName = TextEditingController();
  // final _txtCivilWorkCost = TextEditingController();
  // final _txtMaterialCost = TextEditingController();
  final _txtTotalEstimation = TextEditingController();
  final _txtTenderCost = TextEditingController();
  final _txtProjectId = TextEditingController();
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
                      Expanded(child: _buildCreateProjectForm(isWideScreen)),
                      const SizedBox(width: 20), // Spacing between columns
                      Expanded(child: _buildActiveProjectsListCard(isWideScreen)),
                    ],
                  )
                : Column(
                    // Stack in a single column if screen is narrow
                    children: [
                      _buildCreateProjectForm(isWideScreen),
                      const SizedBox(height: 20), // Spacing between sections
                      _buildActiveProjectsListCard(isWideScreen),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCreateProjectForm(bool isWidthScreen) {
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
                    buildTextField(_txtProjectId, 'Project ID',
                        'Project ID', Icons.key, false, 10),
                    buildTextField(_txtTender, 'Tender',
                        'Enter tender number', Icons.receipt_long, true, 20),
                    buildTextField(_txtProjectName, 'Project Name',
                        'Enter project name', Icons.business, true, 45),
                    buildNumberField(
                        _txtTotalEstimation,
                        'Total Project Estimation',
                        'Enter Estimation',
                        Icons.real_estate_agent_rounded,
                        true,
                        10,null),
                    buildNumberField(_txtTenderCost, 'Tender Cost',
                        'Enter cost', Icons.attach_money, true, 10,null),
                    _buildCheckboxes(),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child:
                  isWidthScreen ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 16,),
                      _buildSubmitButton(),
                      SizedBox(width: 16,),
                      _buildEditButton(),
                      SizedBox(width: 16,),
                      _buildCleanButton(),
                    ],
                    )
                      : Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 16,),
                      _buildSubmitButton(),
                      SizedBox(height: 16,),
                      _buildEditButton(),
                      SizedBox(height: 16,),
                      _buildCleanButton(),
                    ],
                  ),

                )

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
        backgroundColor: Colors.green, // Background color
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
  Widget _buildEditButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          PD.pd(text: "Form is valid!");
          YNDialogCon.ynDialogMessage(
            context,
            messageBody: 'Confirm to Edit existing project',
            messageTitle: 'Project edit',
            icon: Icons.edit_calendar_outlined,
            iconColor: Colors.black,
            btnDone: 'YES',
            btnClose: 'NO',
          ).then((value) async {
            if (value == 1) {
              await updateProjectManagement(context);
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
      child: const Text('Edit Project'),
    );
  }
  Widget _buildCleanButton() {
    return ElevatedButton(
      onPressed: () {
          PD.pd(text: "Form is valid!");
          YNDialogCon.ynDialogMessage(
            context,
            messageBody: 'Confirm to Clear layout ',
            messageTitle: 'layout Clear',
            icon: Icons.edit_calendar_outlined,
            iconColor: Colors.black,
            btnDone: 'YES',
            btnClose: 'NO',
          ).then((value) async {
            if (value == 1) {
               clearText();
            }
          });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Background color
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
      child: const Text('Clear Form'),
    );
  }

  Widget _buildActiveProjectsListCard(bool isWideScreen) {
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
            _buildActiveProjectsList(isWideScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProjectsList(isWideScreen) {
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
                  isWideScreen?
                  Row(
                    children: [IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        PD.pd(text: project.toString());
                        _isActive = project['is_active'] == '0'
                            ? false
                            : true; // Handle null case
                        _userVisible = project['user_visible'] == '0'
                            ? false
                            : true; // Handle null case
                        _txtTender.text =
                            project['tender'] ?? ''; // Update text field
                        _txtProjectName.text =
                            project['project_name'] ?? '';
                        _txtProjectId.text =
                            project['idtbl_projects']?.toString() ?? '0';
                        _txtTotalEstimation.text =
                            project['exp_estimation_cost']?.toString() ?? '';
                        _txtTenderCost.text =
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
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red), // Red color for delete action
                        onPressed: ()


                        async {
                          PD.pd(
                              text:
                              "Deleting project: ${project['idtbl_projects']}");
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
                            _deleteProject(context,project['idtbl_projects']); // Call delete function after confirmation
                          }
                        },
                      ),],
                  ):Column(
                    children: [IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        PD.pd(text: project.toString());
                        _isActive = project['is_active'] == '0'
                            ? false
                            : true; // Handle null case
                        _userVisible = project['user_visible'] == '0'
                            ? false
                            : true; // Handle null case
                        _txtTender.text =
                            project['tender'] ?? ''; // Update text field
                        _txtProjectName.text =
                            project['project_name'] ?? '';
                        _txtProjectId.text =
                            project['idtbl_projects']?.toString() ?? '0';
                        _txtTotalEstimation.text =
                            project['exp_estimation_cost']?.toString() ?? '';
                        _txtTenderCost.text =
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
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red), // Red color for delete action
                        onPressed: ()


                        async {
                          PD.pd(
                              text:
                              "Deleting project: ${project['idtbl_projects']}");
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
                            _deleteProject(context,project['idtbl_projects']); // Call delete function after confirmation
                          }
                        },
                      ),],
                  )

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
          "tender": _txtTender.text,
          "project_name": _txtProjectName.text,
          // "exp_cost_civil_work": 1,
          // "exp_cost_material": 1,
          "exp_estimation_cost": _txtTotalEstimation.text,
           "tender_cost": _txtTenderCost.text,
          "created_by": UserCredentials().UserName,
          "change_by": UserCredentials().UserName,
          "is_active": _isActive,
          "user_visible": _userVisible==true?'1':'0',
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
  Future<void> _deleteProject(BuildContext context, int projectId) async {
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
      String urls = '${APIHost().APIURL}/project_management.php/delete';
      final response = await http.delete(
        Uri.parse(urls),
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
            final String message = responseData['message'];
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


  Future<void> updateProjectManagement(BuildContext context) async {
    try {
      WaitDialog.showWaitDialog(context, message: 'Updating project...');
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
      String url = '${APIHost().APIURL}/project_management.php/edit';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": APIToken().token,
          "tender": _txtTender.text,
          "project_name": _txtProjectName.text,
          "exp_estimation_cost": _txtTotalEstimation.text,
          "tender_cost": _txtTenderCost.text,
          "change_by": UserCredentials().UserName,
          "is_active": _isActive,
          "user_visible": _userVisible==true?1:0,
          "idtbl_projects": _txtProjectId.text,
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
              title: "Successful",
              message: responseData['message'],
              btnName: 'Ok',
              icon: Icons.verified_outlined,
              iconColor: Colors.black,
              btnColor: Colors.green,
            );
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
        String errorMessage =
            'Project update failed with status code ${response.statusCode}';
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
    _txtProjectId.text="";
    _txtTender.text = "";
    _txtProjectName.text = "";
    // _txtCivilWorkCost.text = "";
    // _txtMaterialCost.text = "";
     _txtTotalEstimation.text = "";
     _txtTenderCost.text = "";
    _txtProjectId.text = "";
    _isActive = false;
  }
}
