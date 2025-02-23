import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:roky_holding/env/app_bar.dart';
import 'package:http/http.dart' as http;
import '../env/DialogBoxs.dart';
import '../env/api_info.dart';
import '../env/input_widget.dart';
import '../env/print_debug.dart';

class LocationManagement extends StatefulWidget {
  const LocationManagement({super.key});

  @override
  State<LocationManagement> createState() => _LocationManagementState();
}

class _LocationManagementState extends State<LocationManagement> {
  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dropDownToProject();
    });
  }

  //project list dropdown
  List<dynamic> _activeProjectDropDownMap = [];
  bool _isProjectsDropDown = false;
  Future<void> _dropDownToProject() async {
    setState(() {
      _isProjectsDropDown = true;
    });
    try {
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
  String? _selectedProjectName;
  List<String> _dropdownProjects = [];

  //project location list dropdown
  List<dynamic> _activeProjectLocationDropDownMap = [];
  bool _isProjectLocationDropDown = false;
  Future<void> _dropDownToProjectLocation(String project) async {
    setState(() {
      _isProjectLocationDropDown = true;
    });
    try {
      WaitDialog.showWaitDialog(context, message: 'Loading location');
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
        body: jsonEncode({"Authorization": token,
          "project_name": project}),
      );

      PD.pd(text: reqUrl);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 200) {
          setState(() {
            _activeProjectLocationDropDownMap = responseData['data'] ?? [];
            _dropdownProjectLocation = _activeProjectLocationDropDownMap
                .map<String>((item) => item['location_name'].toString())
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
        _isProjectLocationDropDown = false;
      });
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

    }

  }
  String? _selectedProjectLocationName;
  List<String> _dropdownProjectLocation = [];

  //work list
  final List<dynamic> _activeWorksList = [];
  List<dynamic> _activeWorkListMap = [];
  bool _isLoadingWorksList = false;
  String? _selectedValueWorkType;
  List<String> _dropdownWorkType = [];
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


  //cost category
  String? _selectedValueCostCategory;
  List<String> _dropdownCostCategory = [];
  final List<dynamic> _activeCostList = [];
  List<dynamic> _activeCostListMap = [];
  bool _isLoadingCostList=false;
  Future<void> _loadActiveCostList(String? _workName) async {
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
        body: jsonEncode({"Authorization": token,
          "work_name":_workName,
        }),
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


  String? _selectedValueMaterial;
  List<String> _dropdownMaterial = [];
  final List<dynamic> _activeMaterialList = [];
  List<dynamic> _activeMaterialListMap = [];
  bool _isLoadingMaterialList=false;
  Future<void> _loadActiveMaterialList(String? _workName,String? _costCategory) async {
   // _materialDropDownController.text='';
    _selectedValueMaterial = '';
    _dropdownMaterial.clear();
    _activeMaterialList.clear();
    _activeMaterialListMap.clear();
    _isLoadingMaterialList=false;

    setState(() {
      _isLoadingMaterialList = true;
    });
    try {
      WaitDialog.showWaitDialog(context, message: 'Loading material list');

      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        return;
      }
      String reqUrl =
          '${APIHost().APIURL}/material_controller.php/list_of_category_material';
      final response = await http.post(
        Uri.parse(reqUrl),
        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({
          "Authorization": token,
          "work_name":_workName,
          "cost_category":_costCategory
        }),
      );

      PD.pd(text: reqUrl);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 200) {
          setState(() {
            _activeMaterialListMap = responseData['data'] ?? [];
            _dropdownMaterial = _activeMaterialListMap
                .map<String>((item) => item['material_name'].toString())
                .toList();
          });
          //PD.pd(text: _dropdownMaterial.toString());
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
        _isLoadingMaterialList = false;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }




  //Text field controllers and validation
  final _locationNameController = TextEditingController();
  final _civilWorkCostController = TextEditingController();
  final _filtersCostController = TextEditingController();
  final _serviceCostController = TextEditingController();
  final _labourCostController = TextEditingController();
  final _materialCostController = TextEditingController();
  final _equipmentCostController = TextEditingController();
  final _otherCostController = TextEditingController();
  final _projectDropdownController = TextEditingController();
  final _projectLocationDropdownController = TextEditingController();
  final _materialDropDownController = TextEditingController();
  final _costTypeDropdownController = TextEditingController();
  final _costCategoryDropDownController = TextEditingController();

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
      appBar: const MyAppBar(appname: 'Location Estimation Management'),
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
                      'Estimation Management',
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
                      controller: _projectDropdownController,
                      onChanged: (value) {
                        _selectedProjectName = value;
                        _dropDownToProjectLocation(value.toString());
                      },
                    ),
                    CustomDropdown(
                      label: 'Select Location',
                      suggestions: _dropdownProjectLocation,
                      icon: Icons.location_city,
                      controller: _projectLocationDropdownController,
                      onChanged: (value) {
                        _selectedProjectLocationName = value;
                        _loadActiveWorkList();
                      },
                    ),


                    CustomDropdown(
                      label: 'Work Type',
                      suggestions: _dropdownWorkType,
                      icon: Icons.category_sharp,
                      controller: _costTypeDropdownController,
                      onChanged: (value) {
                        _selectedValueWorkType = value;
                        _loadActiveCostList(value);
                      },
                    ),
                    CustomDropdown(
                      label: 'Select Cost Category',
                      suggestions: _dropdownCostCategory,
                      icon: Icons.celebration,
                      controller: _costCategoryDropDownController,
                      onChanged: (value) {
                        _selectedValueCostCategory = value;
                        PD.pd(text: _selectedValueWorkType.toString());
                        _loadActiveMaterialList( _selectedValueWorkType.toString(),value.toString());
                      },
                    ),
                    CustomDropdown(
                      label: 'Select Material',
                      suggestions: _dropdownMaterial,
                      icon: Icons.token,
                      controller: _materialDropDownController,
                      onChanged: (value) {
                        _selectedValueMaterial = value;
                      //  PD.pd(text: _selectedValueWorkType.toString());
                      },
                    ),
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          PD.pd(text: "Form is valid!");
          PD.pd(
              text:
                  "Selected Work Type: $_selectedValueWorkType");

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
              // await createProjectManagement(context);
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
      child: const Text('Create Costing'),
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
              "Active Costing",
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
      return const Center(child: Text('No active costing found.'));
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
                      // _isActive = project['is_active'] =='0'?false: true; // Handle null case
                      //  _userVisible = project['user_visible'] =='0'?false: true; // Handle null case
                      //  _txtTenderController.text = project['tender'] ?? ''; // Update text field
                      //  _txtProjectNameController.text = project['project_name'] ?? '';
                      //  _txtCivilWorkCostController.text = project['exp_cost_civil_work']?.toString() ?? '';
                      // _txtMaterialCostController.text = project['exp_cost_material']?.toString() ?? '';
                      /// _txtAllocatedCostController.text = project['exp_allocated_cost']?.toString() ?? '';
                      // _txtTenderCostController.text = project['tender_cost']?.toString() ?? '';
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
