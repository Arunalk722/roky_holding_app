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

class MaterialCreate extends StatefulWidget {
  const MaterialCreate({super.key});

  @override
  State<MaterialCreate> createState() => _MaterialCreateState();
}

class _MaterialCreateState extends State<MaterialCreate> {
//
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveWorkList();
    });
  }

  final List<dynamic> _activeWorksList = [];
  List<dynamic> _activeWorkListMap = [];
  bool _isLoadingWorksList = false;



  final List<dynamic> _activeCostList = [];
  List<dynamic> _activeCostListMap = [];
  bool _isLoadingCostList=false;

  Future<void> _loadActiveWorkList() async {
    setState(() {
      _isLoadingWorksList = true;

    });
    try {
      WaitDialog.showWaitDialog(context, message: 'Loading works');

      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        return;
      }

      String reqUrl =
          '${APIHost().APIURL}/material_controller.php/material_work_list';
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
            _activeWorkListMap = responseData['data'] ?? [];
            _dropdownWorkType = _activeWorkListMap
                .map<String>((item) => item['work_name'].toString())
                .toList();
          });
          _loadActiveCostList();
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
        _isLoadingWorksList = false;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }


  Future<void> _loadActiveCostList() async {
    setState(() {
      _isLoadingCostList = true;
    });
    try {
      WaitDialog.showWaitDialog(context, message: 'Loading works');

      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        return;
      }

      String reqUrl =
          '${APIHost().APIURL}/material_controller.php/cost_category_list';
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
            _activeCostListMap = responseData['data'] ?? [];
            _dropdownCostCategory = _activeCostListMap
                .map<String>((item) => item['cost_category'].toString())
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
        _isLoadingCostList = false;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }


  String? _selectedValueWorkType;
  List<String> _dropdownWorkType = [];
  bool _allowUserToEdit=false;

  String? _selectedValueCostCategory;
  List<String> _dropdownCostCategory = [];

  final _costTypeDropdownController = TextEditingController();
  final _costCategoryDropDownController = TextEditingController();

  final TextEditingController _materialName = TextEditingController();
  final TextEditingController _materialCost= TextEditingController();
  final TextEditingController _qty= TextEditingController();
  void _clearText(){
    _allowUserToEdit=false;
    _materialCost.text='';
    _qty.text='';
    _materialName.text='';
    _costCategoryDropDownController.text='';
    _costTypeDropdownController.text='';
    setState(() {
    });
  }

  Future<void> createMaterials(BuildContext context) async {
    // Add BuildContext
    try {
      WaitDialog.showWaitDialog(context, message: 'project Material');
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
      String a = '${APIHost().APIURL}/material_controller.php/create_material';
      final response = await http.post(
        Uri.parse(a),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": APIToken().token,
          "work_name": _selectedValueWorkType,
          "cost_category": _selectedValueCostCategory,
          "material_name":_materialName.text,
          "qty": _qty.text,
          "amount": _materialCost.text,
          "created_by": UserCredentials().UserName,
          "is_edit_allow": _allowUserToEdit==true?1:0
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
            _clearText();
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
            'Material creating failed with status code ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(appname: 'Material Management'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Center(
                    child: Text(
                      'Create a Materials',
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
                      label: 'Work Type',
                      suggestions: _dropdownWorkType,
                      icon: Icons.category_sharp,
                      controller: _costTypeDropdownController,
                      onChanged: (value) {
                        _selectedValueWorkType = value;
                      },
                    ),
                    CustomDropdown(
                      label: 'Select Cost Category',
                      suggestions: _dropdownCostCategory,
                      icon: Icons.celebration,
                      controller: _costCategoryDropDownController,
                      onChanged: (value) {
                        _selectedValueCostCategory = value;
                      },
                    ),

                     BuildTextField(
                              _materialName,
                              'Material Name/Work Name',
                              'Cement (50 Kg bags)/Paint work',
                              Icons.description,
                              true,
                              45),
                    Row(
                      children: [
                        Expanded(
                          flex:5 ,
                          child: BuildNumberField(
                              _qty,
                              'Qty',
                              '1',
                              Icons.numbers,
                              true,
                              5
                          ),
                        ),
                        SizedBox(width: 10), // Space between fields
                        Expanded( flex:5 ,
                          child: BuildNumberField(
                              _materialCost,
                              'Material Cost/Work Cost',
                              '1500 LKR',
                              Icons.attach_money,
                              true,
                              10,)
                        ),
                      ],
                    ),
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
                value: _allowUserToEdit,
                onChanged: (bool? newValue) {
                  setState(() {
                    _allowUserToEdit = newValue ?? false;
                  });
                },
                activeColor: Colors.blueAccent,
              ),
              const Text('Allow User to edit price'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
          PD.pd(text: "Form is valid!");
          PD.pd(
              text:
              "Selected Work Type: $_allowUserToEdit");

          YNDialogCon.ynDialogMessage(
            context,
            messageBody: 'Confirm to create a new Material',
            messageTitle: 'Material Creating',
            icon: Icons.verified_outlined,
            iconColor: Colors.black,
            btnDone: 'YES',
            btnClose: 'NO',
          ).then((value) async {
            if (value == 1) {
               await createMaterials(context);
            }
          });

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
      child: const Text('Create Material'),
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
              "Active Material",
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
    if (_isLoadingWorksList) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeWorksList.isEmpty) {
      return const Center(child: Text('No active materials found.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activeWorksList.length,
      itemBuilder: (context, index) {
        final project = _activeWorksList[index];
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
                        //  _changeVisibility(context, '${project['idtbl_projects']}', project['user_visible'] =='0'?false: true);
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
                        //_deleteProject(context,'${project['idtbl_projects']}'); // Call delete function after confirmation
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
}


