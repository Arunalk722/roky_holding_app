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


  Future<void> updateLocation(BuildContext context, int idtbl_project_location, int project_id, String location_name, String is_active) async {
    try {
      // Show loading message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updating location...'), duration: Duration(seconds: 2)),
      );

      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        // If token is missing, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication token is missing."), backgroundColor: Colors.red),
        );
        return;
      }

      String url = '${APIHost().APIURL}/location_controller.php/edit_location_name';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": APIToken().token,
          "idtbl_project_location": idtbl_project_location,
          "project_id": project_id,
          "location_name": location_name,
          "is_active": 1,
          "change_by": UserCredentials().UserName,
        }),
      );

      if (response.statusCode == 200) {
        // Hide loading message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated successfully'), backgroundColor: Colors.green),
        );

        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final int status = responseData['status'];

          if (status == 200) {
            // Success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? 'Success'), backgroundColor: Colors.green),
            );
          } else {
            final String message = responseData['message'] ?? 'Error';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          }
        } catch (e) {
          // JSON decoding error
          String errorMessage = "Error decoding JSON: $e, Body: ${response.body}";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      } else {
        String errorMessage = 'Error with status code ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (e) {
            errorMessage = response.body;
          }
        }
        // Display error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      String errorMessage = 'An error occurred: $e';
      if (e is FormatException) {
        errorMessage = 'Invalid JSON response';
      } else if (e is SocketException) {
        errorMessage = 'Network error. Please check your connection.';
      }
      // Display network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }




  //project list dropdown
  List<dynamic> _activeProjectDropDownMap = [];
  bool _isProjectsDropDown = false;
  Future<void> _dropDownToProject() async {
    setState(() {
      _isProjectsDropDown = true;
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
            _activeProjectDropDownMap = responseData['data'] ?? [];
            _dropdownProjects = _activeProjectDropDownMap
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
        _isProjectsDropDown = false;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  //select project dropdown
  String? _selectedProjectName;
  List<String> _dropdownProjects = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dropDownToProject();
    });
  }

  //project location list
  List<dynamic> _activeProjectsLocationList = [];
  bool _isProjectsLocationLoad = false;
  Future<void> _loadProjectsLocationList(String project) async {
    setState(() {
      _isProjectsLocationLoad = true;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading project...'), duration: Duration(seconds: 2)),
      );

      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        return;
      }

      String reqUrl = '${APIHost().APIURL}/location_controller.php/project_location_list';
      final response = await http.post(
        Uri.parse(reqUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": token,
          "project_name": project,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['status'] == 200) {
          setState(() {
            _activeProjectsLocationList = List.from(responseData['data'] ?? []);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project locations loaded successfully'), backgroundColor: Colors.green),
          );
        } else {
          final String message = responseData['message'] ?? 'Error';
          PD.pd(text: message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("HTTP Error: ${response.statusCode}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isProjectsLocationLoad = false;
      });
    }
  }

  Future<void> _loadTenderNumber(String project) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finding tender...'), duration: Duration(seconds: 2)),
      );

      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        return;
      }

      String reqUrl = '${APIHost().APIURL}/project_management.php/tender_find';
      final response = await http.post(
        Uri.parse(reqUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": token,
          "project_name": project,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['status'] == 200) {
          List<dynamic> dataList = responseData['data'] ?? [];
          for (var item in dataList) {
            if (item.containsKey('tender')) {
              _txtTender.text = item['tender'];
            }
          }

          setState(() {});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tender number found'), backgroundColor: Colors.green),
          );

          _loadProjectsLocationList(project);
        } else {
          final String message = responseData['message'] ?? 'Error';
          PD.pd(text: message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("HTTP Error: ${response.statusCode}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }




  // Text field controllers and validation
  final _txtLocationNameController = TextEditingController();
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
    _txtLocationNameController.dispose();
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
                        _loadTenderNumber(_selectedProjectName.toString());

                      },
                    ),

                    buildTextField(_txtLocationName, 'Location Name',
                        'Building construction downtown', Icons.create, true, 45),
                    buildTextField(
                        _txtTender, 'Tender Number', 'TX00001', Icons.query_builder, true, 20),
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
     // PD.pd(text: "Response: ${response.statusCode} - ${response.body}");
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
            createNewEstimationId();

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
            'Project Management location creating failed with status code ${response
            .statusCode}';
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


  Future<void> createNewEstimationId() async {
    // Add BuildContext
    try {
      WaitDialog.showWaitDialog(context, message: 'location estimations');
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
      String a = '${APIHost().APIURL}/estimation_management.php/create_estimation';
      final response = await http.post(
        Uri.parse(a),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": APIToken().token,
          "location_name": _txtLocationName.text,
          "project_name": _selectedProjectName.toString(),
          "is_active": '1',
          "created_by": UserCredentials().UserName,
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
            _loadProjectsLocationList(_selectedProjectName.toString());
          }
          else if (status == 409) {
            PD.pd(text: responseData.toString());
            OneBtnDialog.oneButtonDialog(context,
                title: "Scanning",
                message: responseData['message'],
                btnName: 'Ok',
                icon: Icons.find_in_page,
                iconColor: Colors.black,
                btnColor: Colors.green);
          }
          else {
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
            'estimation creating failed with status code ${response
            .statusCode}';
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
        backgroundColor: Colors.blue,
        // Background color
        foregroundColor: Colors.white,
        // Text color
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500, // Font weight
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        // Elevation
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
    if (_isProjectsLocationLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeProjectsLocationList.isEmpty) {
      return const Center(
          child: Text(
            'No active costing found.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activeProjectsLocationList.length,
      itemBuilder: (context, index) {
        final location = _activeProjectsLocationList[index];
        TextEditingController _txtLocationNameController = TextEditingController(
            text: location['location_name']);
        TextEditingController _txtProjectName = TextEditingController(
            text: location['project_name']);
        TextEditingController _txtTender = TextEditingController(
            text: location['tender_cost']);
        TextEditingController _txtEstimation = TextEditingController(
            text: location['exp_estimation_cost']);


        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.blue.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business, color: Theme.of(context).primaryColor, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTextFieldReadOnly(
                                _txtProjectName, 'Project Name', '', Icons.construction, true, 45),
                            buildTextField(
                                _txtLocationNameController, 'Location Name', '', Icons.pin_drop, true, 45),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Divider(thickness: 1, color: Colors.grey),

                  // Row for Estimated Cost and Tender Cost
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildTextFieldReadOnly(
                          _txtEstimation,
                          'Estimated Cost',
                          '',
                          Icons.attach_money,
                          true,
                          20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildTextFieldReadOnly(
                          _txtTender,
                          'Tender Cost',
                          '',
                          Icons.attach_money,
                          true,
                          20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Divider(thickness: 1, color: Colors.grey),

                  buildDetailRow(
                    'Created:',
                    '${location['created_by']} on ${location['created_date']}',

                  ),
                  buildDetailRow(
                    'Changed:',
                    '${location['change_by']} on ${location['change_date']}',

                  ),

                  // Save Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Save', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        updateLocation(
                          context,
                          location['idtbl_project_location'],
                          location['project_id'],
                          _txtLocationNameController.text,
                          _txtProjectName.text
                        );
                      },
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

}

//
// Widget BuildDetailRow(String label, TextEditingController controller) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 140,
//           child: Text(
//             label,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: Colors.blueGrey,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: Colors.blueAccent,
//                 width: 1,
//               ),
//             ),
//             child: TextField(
//               controller: controller,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.black87,
//               ),
//               decoration: const InputDecoration(
//                 border: InputBorder.none,
//                 hintText: 'Enter value...',
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

