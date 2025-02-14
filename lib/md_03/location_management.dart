import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:roky_holding/env/app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:roky_holding/env/user_data.dart';
import '../env/DialogBoxs.dart';
import '../env/api_info.dart';
import '../env/input_widget.dart';
import '../env/print_debug.dart';

class LocationCostCreate extends StatefulWidget {
  const LocationCostCreate({super.key});

  @override
  State<LocationCostCreate> createState() => _LocationCostCreateState();
}

class _LocationCostCreateState extends State<LocationCostCreate> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _txtLocationName = TextEditingController();
  final TextEditingController _txtTender = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dropDownToProject();
    });
  }

  List<dynamic> _activeDropDownMap = [];
  bool _isDropDownToProjects = false;
  Future<void> _dropDownToProject() async {
    setState(() {
      _isDropDownToProjects = true;
    });
    try {
      WaitDialog.showWaitDialog(context, message: 'Loading items');

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
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 200) {
          setState(() {
            _activeDropDownMap = responseData['data'] ?? [];
            _dropdownProjects = _activeDropDownMap
                .map<String>((item) => item['project_name'].toString())
                .toList();
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
        _isDropDownToProjects = false;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  List<dynamic> _activeProjects = [];
  bool _isLoadingProjects = false;
  Future<void> _loadProjects(String project) async {
    setState(() {
      _isLoadingProjects = true;
    });

    try {
      WaitDialog.showWaitDialog(context, message: 'Loading project');

      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        return;
      }

      String reqUrl =
          '${APIHost().APIURL}/location_controller.php/project_location_list';
      final response = await http.post(
        Uri.parse(reqUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"Authorization": token, "project_name": project}),
      );

      PD.pd(text: reqUrl);

      if (response.statusCode == 200) {
        try {
          final responseData =
              jsonDecode(response.body) as Map<String, dynamic>;

          // Check the status and process the response data
          if (responseData['status'] == 200) {
            // Extract data from the response
            setState(() {
              _activeProjects = List.from(responseData['data'] ?? []);
            });

            // Print out the data for debugging
            PD.pd(text: _activeProjects.toString());
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

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  String? _selectedProjectName;
  List<String> _dropdownProjects = [];

  // Text field controllers and validation
  final _locationNameController = TextEditingController();
  final _civilWorkCostController = TextEditingController();
  final _filtersCostController = TextEditingController();
  final _serviceCostController = TextEditingController();
  final _labourCostController = TextEditingController();
  final _materialCostController = TextEditingController();
  final _equipmentCostController = TextEditingController();
  final _otherCostController = TextEditingController();
  final _dropdown1Controller = TextEditingController();
  final _dropdown2Controller = TextEditingController();

  double _totalCost = 0;

  @override
  void dispose() {
    _locationNameController.dispose();
    _civilWorkCostController.dispose();
    _filtersCostController.dispose();
    _serviceCostController.dispose();
    _labourCostController.dispose();
    _materialCostController.dispose();
    _equipmentCostController.dispose();
    _otherCostController.dispose();
    super.dispose();
  }

  void _calculateTotalCost() {
    setState(() {
      _totalCost = 0;
      _totalCost += double.tryParse(_civilWorkCostController.text) ?? 0;
      _totalCost += double.tryParse(_filtersCostController.text) ?? 0;
      _totalCost += double.tryParse(_serviceCostController.text) ?? 0;
      _totalCost += double.tryParse(_labourCostController.text) ?? 0;
      _totalCost += double.tryParse(_materialCostController.text) ?? 0;
      _totalCost += double.tryParse(_equipmentCostController.text) ?? 0;
      _totalCost += double.tryParse(_otherCostController.text) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appname: 'Project Location Management'),
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
                      Expanded(child: _buildCreateLocationForm()),
                      const SizedBox(width: 20), // Spacing between columns
                      Expanded(child: _buildActiveLocationCostListCard()),
                    ],
                  )
                : Column(
                    // Stack in a single column if screen is narrow
                    children: [
                      _buildCreateLocationForm(),
                      const SizedBox(height: 20), // Spacing between sections
                      _buildActiveLocationCostListCard(),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCreateLocationForm() {
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
                      'Create New Location',
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
                    CustomDropdown(
                      label: 'Select Project',
                      suggestions: _dropdownProjects,
                      icon: Icons.category_sharp,
                      controller: _dropdown1Controller,
                      onChanged: (value) {
                        _selectedProjectName = value;
                        _loadProjects(_selectedProjectName.toString());
                      },
                    ),

                    buildTextField(_txtLocationName, 'Location Name',
                        'Colombo water', Icons.key, true, 45),
                    buildTextField(
                        _txtTender, 'Tender', 'TX00001', Icons.key, true, 20),
                    //  _buildCheckboxes(),
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

  Future<void> createProjectLocation(BuildContext context) async {
    // Add BuildContext
    try {
      WaitDialog.showWaitDialog(context, message: 'location creating');
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
      String a = '${APIHost().APIURL}/location_controller.php/create';
      final response = await http.post(
        Uri.parse(a),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": APIToken().token,
          "project_name": _selectedProjectName.toString(),
          "location_name": _txtLocationName.text,
          "tender": _txtTender.text,
          "is_active": "1",
          "created_by": UserCredentials().UserName,
          "change_by": UserCredentials().UserName,
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
            _loadProjects(_selectedProjectName.toString());
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
            'Project Management location creating failed with status code ${response.statusCode}';
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          PD.pd(text: "Form is valid!");
          PD.pd(
              text:
                  "Selected Cost Type: $_selectedProjectName"); // Print selected cost type

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
              await createProjectLocation(context);
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
      child: const Text('Create Locations'),
    );
  }

  Widget _buildActiveLocationCostListCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Active Location",
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
      return const Center(child: Text('No active costing found.'));
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
                          project['location_name'] ?? 'Project Name',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tender: ${project['project_id'] ?? 'Tender Number'}',
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
                      // _isActive = project['is_active'] =='0'?false: true; // Handle null case
                      //  _userVisible = project['user_visible'] =='0'?false: true; // Handle null case
                      //  _txtTenderController.text = project['tender'] ?? ''; // Update text field
                      //  _txtProjectNameController.text = project['project_name'] ?? '';
                      //  _txtCivilWorkCostController.text = project['exp_cost_civil_work']?.toString() ?? '';
                      // _txtMaterialCostController.text = project['exp_cost_material']?.toString() ?? '';
                      /// _txtAllocatedCostController.text = project['exp_allocated_cost']?.toString() ?? '';
                      // _txtTenderCostController.text = project['tender_cost']?.toString() ?? '';
                      setState(() {});
                      //  PD.pd(text: "View project: ${project['tender']}");
                    },
                  ),
                  // IconButton(
                  //   icon: Icon(project['user_visible'] as int==1?Icons.visibility_off_outlined:Icons.visibility),color: project['user_visible'] as int==1?Colors.blue:Colors.red,
                  //   onPressed: () async {
                  //     int vis = project['user_visible'] as int;
                  //     String mg =vis==0?'visibility enable':'visibility disable';
                  //     int result = await YNDialogCon.ynDialogMessage(
                  //       context,
                  //       messageTitle: mg,
                  //       messageBody: "Are you sure you want to ${mg} project ${project['tender']}?",
                  //       icon: vis==0?Icons.visibility:Icons.visibility_off_outlined,
                  //       iconColor: Colors.orange,
                  //       btnDone: vis==0?"Yes, Visible":"Yes, Invisible",
                  //       btnClose: "Cancel",
                  //     );
                  //     if (result == 1) {
                  //       //  _changeVisibility(context, '${project['idtbl_projects']}', project['user_visible'] =='0'?false: true);
                  //     }
                  //   },
                  // ),
                  // Delete Button
                  // IconButton(
                  //   icon: const Icon(Icons.delete, color: Colors.red), // Red color for delete action
                  //   onPressed: () async {
                  //     int result = await YNDialogCon.ynDialogMessage(
                  //       context,
                  //       messageTitle: "Confirm Deletion",
                  //       messageBody: "Are you sure you want to delete project ${project['tender']}?",
                  //       icon: Icons.warning,
                  //       iconColor: Colors.orange,
                  //       btnDone: "Yes, Delete",
                  //       btnClose: "Cancel",
                  //     );
                  //
                  //     if (result == 1) {
                  //     //  PD.pd(text: "Deleting project: ${project['idtbl_projects']}");
                  //       //_deleteProject(context,'${project['idtbl_projects']}'); // Call delete function after confirmation
                  //     }
                  //   },
                  // ),

                  // const Icon(Icons.arrow_forward_ios, size: 16), // Optional arrow
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
