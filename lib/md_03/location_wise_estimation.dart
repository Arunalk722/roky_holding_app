import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:roky_holding/env/app_bar.dart';
import 'package:http/http.dart' as http;
import '../env/DialogBoxs.dart';
import '../env/api_info.dart';
import '../env/input_widget.dart';
import '../env/print_debug.dart';
import '../env/user_data.dart';

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

  //loading estimation
  List<dynamic> _activeEstimationList = [];
  bool _isEstimationLoad = false;
  Future<void> _loadProjectsLocationEstimationList() async {
    _activeEstimationList.clear();
    setState(() {
      _isEstimationLoad = true;
    });

    try {
      //WaitDialog.showWaitDialog(context, message: 'Loading estimations');
      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        return;
      }
      String reqUrl =
          '${APIHost().APIURL}/estimation_management.php/get_lw_estimation_list';
      final response = await http.post(
        Uri.parse(reqUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"Authorization": token,
          "project_name": _selectedProjectName.toString(),
          "location_name":_selectedProjectLocationName.toString()
        }),
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
              _activeEstimationList = List.from(responseData['data'] ?? []);
            });

            // Print out the data for debugging
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
        _isEstimationLoad = false;
      });

      // if (Navigator.canPop(context)) {
      //   Navigator.pop(context);
      // }
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
      //WaitDialog.showWaitDialog(context, message: 'Loading project');
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
      // if (Navigator.canPop(context)) {
      //   Navigator.pop(context);
      // }

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
      //WaitDialog.showWaitDialog(context, message: 'Loading location');
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
      // if (Navigator.canPop(context)) {
      //   Navigator.pop(context);
      // }

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
  //    //WaitDialog.showWaitDialog(context, message: 'Loading works');

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

      // if (Navigator.canPop(context)) {
      //   Navigator.pop(context);
      // }
    }
  }


  //cost category
  String? _selectedValueCostCategory;
  List<String> _dropdownCostCategory = [];
  final List<dynamic> _activeCostList = [];
  List<dynamic> _activeCostListMap = [];
  bool _isLoadingCostList=false;
  Future<void> _loadActiveCostList(String? workName) async {
    setState(() {
      _isLoadingCostList = true;
    });
    try {
      //WaitDialog.showWaitDialog(context, message: 'Loading works');

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
          "work_name":workName,
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

      // if (Navigator.canPop(context)) {
      //   Navigator.pop(context);
      // }
    }
  }


  String? _selectedValueMaterial;
  List<String> _dropdownMaterial = [];
  final List<dynamic> _activeMaterialList = [];
  List<dynamic> _activeMaterialListMap = [];
  bool _isLoadingMaterialList=false;
  Future<void> _loadActiveMaterialList(String? workName,String? costCategory) async {
    setState(() {
      _isLoadingMaterialList = true;
    });
    try {
     // //WaitDialog.showWaitDialog(context, message: 'Loading material list');

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
          "work_name":workName,
          "cost_category":costCategory
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

      // if (Navigator.canPop(context)) {
      //   Navigator.pop(context);
      // }
    }
  }




  //Text field controllers and validation

  final _txtProjectDropdown = TextEditingController();
  final _txtProjectLocationDropdown = TextEditingController();
  final _txtMaterialDropDown = TextEditingController();
  final _txtCostTypeDropdown = TextEditingController();
  final _txtCostCategoryDropDown = TextEditingController();
  final _txtQty = TextEditingController();
  final _txtEstimationAmount = TextEditingController();
  final _txtDescriptions = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }


  String? _materialId;
  String? _price;
  String? _qty;
  String? _unit;
  double amount=0;

  void _updateAmount() {
    if(_txtEstimationAmount.text=='0'||_txtEstimationAmount.text.length<=0)
    {
      try {
        double qty = double.tryParse(_txtQty.text) ?? 0;
        double price = double.tryParse(_price.toString()) ?? 0;
        setState(() {
          amount = qty * price;
        });
        _txtEstimationAmount.text=amount.toString();
      } catch (e) {

      }
    }else{

    }
  }

  Future<void> _loadMaterialInfo(String? workName, String? costCategory, String? materialName) async {
    try {
      //WaitDialog.showWaitDialog(context, message: 'Loading material list');

      String? token = APIToken().token;
      if (token == null || token.isEmpty) {
        PD.pd(text: "Error: No API token found.");
        return;
      }

      String reqUrl = '${APIHost().APIURL}/material_controller.php/get_material_info';

      final response = await http.post(
        Uri.parse(reqUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": token, // Keeping Authorization in the body as per your request
          "work_name": workName,
          "cost_category": costCategory,
          "material_name": materialName,
        }),
      );

      PD.pd(text: reqUrl);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 200) {
          if (responseData['data'] is List && responseData['data'].isNotEmpty) {
            final materialData = responseData['data'][0];
            setState(() {
              _materialId = materialData['idtbl_material_list'].toString();
              _qty = materialData['qty'];
              _price = materialData['amount'];
              _unit=materialData['uom'];
              _txtDescriptions.text = materialData['material_name'];
            });
            PD.pd(text: responseData.toString());
            PD.pd(text: "Material ID: $_materialId");
          } else {
            PD.pd(text: "Error: No material data found.");
            _showErrorDialog("No material data found.");
          }
        } else {
          final String message = responseData['message'] ?? 'Unknown Error';
          PD.pd(text: message);
          _showErrorDialog(message);
        }
      } else {
        PD.pd(text: "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      PD.pd(text: "Exception: $e");
      _showErrorDialog("An error occurred while fetching materials.");
    } finally {
      setState(() {
        _isLoadingMaterialList = false;
      });

      // if (Navigator.canPop(context)) {
      //   Navigator.pop(context);
      // }
    }
  }

  void _showErrorDialog(String message) {
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


  Future<void> createEstimationList() async {
    // Add BuildContext
    try {
      //WaitDialog.showWaitDialog(context, message: 'location estimations');
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

      String a = '${APIHost().APIURL}/estimation_management.php/Create_Estimation_List';
      final response = await http.post(
        Uri.parse(a),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "Authorization": APIToken().token,
          "location_name": _selectedProjectLocationName.toString(),
          "project_name": _selectedProjectName.toString(),
          "idtbl_material_list": _materialId,
          "is_active": '1',
          "created_by": UserCredentials().UserName,
          "estimate_amount": _txtEstimationAmount.text,
          "estimation_gap":"0",
          "estimate_qty":_txtQty.text,
          "material_description":_txtDescriptions.text
        }),
      );

      PD.pd(text: "Response: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200) {
       // WaitDialog.hideDialog(context);
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
            //  _loadProjectsLocationList(_selectedProjectName.toString());

            clearData();
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
       // WaitDialog.hideDialog(context);
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
     // WaitDialog.hideDialog(context);
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
     // //WaitDialog.showWaitDialog(context, message: 'location estimations');
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
          "location_name": _selectedProjectLocationName.toString(),
          "project_name": _selectedProjectName.toString(),
          "is_active": '1',
          "created_by": UserCredentials().UserName,
        }),
      );
      PD.pd(text: "Response: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200) {
      // // WaitDialog.hideDialog(context);
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
            //  _loadProjectsLocationList(_selectedProjectName.toString());

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
            _loadProjectsLocationEstimationList();
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
      // // WaitDialog.hideDialog(context);
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
     //// WaitDialog.hideDialog(context);
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

  void clearData(){
    _materialId='';
    _price='';
    _qty='';
    _unit='';
    amount=0;
    _txtEstimationAmount.text='';
    _txtQty.text='';
    _txtDescriptions.text='';
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
                Expanded(child: _buildCreateEstimationForm()),
                const SizedBox(width: 20), // Spacing between columns
                Expanded(child: _buildActiveEstimationListCard()),
              ],
            )
                : Column(
              // Stack in a single column if screen is narrow
              children: [
                _buildCreateEstimationForm(),
                const SizedBox(height: 20), // Spacing between sections
                _buildActiveEstimationListCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateEstimationForm() {
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
                      controller: _txtProjectDropdown,
                      onChanged: (value) {
                        _selectedProjectName = value;
                        _dropDownToProjectLocation(value.toString());
                      },
                    ),
                    CustomDropdown(
                      label: 'Select Location',
                      suggestions: _dropdownProjectLocation,
                      icon: Icons.location_city,
                      controller: _txtProjectLocationDropdown,
                      onChanged: (value) {
                        _selectedProjectLocationName = value;
                        createNewEstimationId();
                        _loadActiveWorkList();
                      },
                    ),
                    CustomDropdown(
                      label: 'Work Type',
                      suggestions: _dropdownWorkType,
                      icon: Icons.category_sharp,
                      controller: _txtCostTypeDropdown,
                      onChanged: (value) {
                        _selectedValueWorkType = value;
                        _loadActiveCostList(value);
                      },
                    ),
                    CustomDropdown(
                      label: 'Select Cost Category',
                      suggestions: _dropdownCostCategory,
                      icon: Icons.celebration,
                      controller: _txtCostCategoryDropDown,
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
                      controller: _txtMaterialDropDown,
                      onChanged: (value) {
                        _selectedValueMaterial = value;
                        _loadMaterialInfo(_selectedValueWorkType.toString(),_selectedValueCostCategory.toString(),_selectedValueMaterial.toString());
                        //  PD.pd(text: _selectedValueWorkType.toString());
                      },
                    ),
                    buildTextField(_txtDescriptions, 'Descriptions', 'Cement', Icons.description, true, 45),
                    Visibility(
                        visible: false,
                        child: Column(
                          children:<Widget> [
                            buildDetailRow('Material ID',_materialId ),
                            buildDetailRow('Price', _price),
                            buildDetailRow('Qty', '$_qty $_unit'),
                          ],
                        )),
                    Row(
                      children: [
                        Expanded(
                          flex:5 ,
                          child:
                          buildNumberField(
                            _txtQty,
                            'Estimate Qty',
                            '1',
                            Icons.numbers,
                            true,
                            5,
                                (value) {
                              print('User entered: $value'); // Example action
                            },
                          ),),

                        SizedBox(width: 10), // Space between fields
                        Expanded( flex:5 ,
                            child: buildNumberField(
                                _txtEstimationAmount,
                                'Estimate Material Cost/Work Cost',
                                '1500 LKR',
                                Icons.attach_money,
                                true,
                                10,null)
                        ),
                      ],
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
        _updateAmount();
        if (_formKey.currentState!.validate()) {
          PD.pd(text: "Form is valid!");
          PD.pd(
              text:
              "Selected Work Type: $_selectedValueWorkType");

          YNDialogCon.ynDialogMessage(
            context,
            messageBody: 'Confirm to adding items estimation',
            messageTitle: 'estimations making',
            icon: Icons.verified_outlined,
            iconColor: Colors.black,
            btnDone: 'YES',
            btnClose: 'NO',
          ).then((value) async {
            if (value == 1) {
              await createEstimationList();
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
      child: const Text('Create estimation'),
    );
  }

  Widget _buildActiveEstimationListCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Active Project Estimation",
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
    if (_isEstimationLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeEstimationList.isEmpty) {
      return const Center(
          child: Text(
            'No active estimation found.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activeEstimationList.length,
      itemBuilder: (context, index) {
        final estimation = _activeEstimationList[index];

        TextEditingController _txtMaterialDescription = TextEditingController(
            text: estimation['material_description'].toString());

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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon(Icons.lo, color: Theme.of(context).primaryColor, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: buildDetailRow('Estimation ID', estimation['estimation_id'].toString())),
                        Visibility(visible: false,child: buildDetailRow('List ID', estimation['idtbl_project_location_estimations_list'].toString()),),
                        buildDetailRow('Material', estimation['idtbl_material_list'].toString()),
                        buildDetailRow('Qty', estimation['estimate_qty'].toString()),
                        buildDetailRow('Amount', '${estimation['estimate_amount']}.LKR'),
                        buildDetailRow('Actual Cost', '${estimation['actual_cost']}.LKR'),
                        buildDetailRow('Unit Cost', '${estimation['actual_unit_amount']}.LKR'),

                        buildTextFieldReadOnly(
                            _txtMaterialDescription, 'Material', '', Icons.construction, true, 45),

                        const Divider(thickness: 1, color: Colors.grey),

                        buildDetailRow(
                          'Created:',
                          '${estimation['created_by']} on ${estimation['created_date']}',
                        ),
                        buildDetailRow(
                          'Changed:',
                          '${estimation['change_by']} on ${estimation['change_date']}',
                        ),
                      ],
                    ),
                  ),

                  // Save Button with Color
                  IconButton(
                    icon: const Icon(Icons.save, color: Colors.green, size: 28),
                    onPressed: () {
                      // Call API to save updates
                    },
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
