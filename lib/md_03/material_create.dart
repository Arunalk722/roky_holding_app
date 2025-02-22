import 'dart:convert';
import 'dart:ffi';
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


  final List<dynamic> _activeMaterialList = [];
   List<dynamic> _activeMaterialListMap = [];
   bool _isLoadingMaterials = false;

  Future<void> _loadMaterials(String? _workName,String? _costCategory) async {


    setState(() {
      _isLoadingMaterials = true;
    });
    try {
      WaitDialog.showWaitDialog(context, message: 'Loading works');

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
            _activeMaterialList.clear();
            _activeMaterialList.addAll(_activeMaterialListMap);
            PD.pd(text: _activeMaterialListMap.toString());
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
        _isLoadingMaterials = false;
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
                        _loadActiveCostList(value);
                        setState(() {

                        });
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

                        _loadMaterials(_selectedValueWorkType.toString(),_selectedValueCostCategory.toString());
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
            _buildActiveMaterialList(),
          ],
        ),
      ),
    );
  }
  Widget _buildActiveMaterialList() {
    if (_isLoadingMaterials) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeMaterialListMap.isEmpty) {
      return const Center(child: Text('No active materials found.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activeMaterialListMap.length,
      itemBuilder: (context, index) {
        final material = _activeMaterialListMap[index];
        return Card(
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
                          material['material_name'] ?? 'Material Name',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Work Type: ${material['work_name'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Qty: ${material['qty'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Amount: ${material['amount'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(material['is_active'] == 1
                        ? Icons.visibility
                        : Icons.visibility_off_outlined),
                    color: material['is_active'] == 1 ? Colors.blue : Colors.red,
                    onPressed: () {
                      PD.pd(text: "Toggled visibility for: ${material['material_name']}");
                    },
                  ),
                  IconButton(
                    icon: Icon( Icons.edit),
                    color: Colors.blue,
                    onPressed: () {
                      _showMaterialInputDialog(
                        context,
                        material['idtbl_material_list'],
                        material['material_name'],
                        double.tryParse(material['amount'].toString()) ?? 0.0, // Safely convert to double
                        double.tryParse(material['qty'].toString()) ?? 0.0,
                      );

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
class MaterialInputDialog extends StatefulWidget {
  final int itemId;
  final String materialName;
  final double amount;
  final double qty;

  const MaterialInputDialog({
    Key? key,
    required this.itemId,
    required this.materialName,
    required this.amount,
    required this.qty,
  }) : super(key: key);

  @override
  _MaterialInputDialogState createState() => _MaterialInputDialogState();
}

class _MaterialInputDialogState extends State<MaterialInputDialog> {
  late TextEditingController _qtyController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.qty.toString());
    _amountController = TextEditingController(text: widget.amount.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.materialName),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final double updatedQty = double.tryParse(_qtyController.text) ?? 0.0;
            final double updatedAmount = double.tryParse(_amountController.text) ?? 0.0;

            changePrice(context, widget.itemId, updatedQty, updatedAmount);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 5.0,
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

Future<void> changePrice(BuildContext context, int materialId, double qty, double amount) async {

  WaitDialog.showWaitDialog(context, message: 'Updating Price');
  try {
    WaitDialog.showWaitDialog(context, message: 'Updating Price');
    String? token = APIToken().token;
    if (token == null || token.isEmpty) {
      PD.pd(text: "Authentication token is missing.");
      return;
    }

    final response = await http.post(
      Uri.parse('${APIHost().APIURL}/material_controller.php/edit_price'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Authorization": token,
        "idtbl_material_list": materialId,
        "qty": qty,
        "amount": amount,
        "change_by": UserCredentials().UserName
      }),
    );

    WaitDialog.hideDialog(context);
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['status'] == 200) {
      OneBtnDialog.oneButtonDialog(context,
          title: "Successful",
          message: responseData['message'],
          btnName: 'Ok',
          icon: Icons.verified_outlined,
          iconColor: Colors.black,
          btnColor: Colors.green);
    } else {
      OneBtnDialog.oneButtonDialog(context,
          title: 'Error',
          message: responseData['message'] ?? 'Update failed',
          btnName: 'OK',
          icon: Icons.error,
          iconColor: Colors.red,
          btnColor: Colors.black);
    }
  } catch (e) {
    WaitDialog.hideDialog(context);
    ExceptionDialog.exceptionDialog(
      context,
      title: 'Error',
      message: e.toString(),
      btnName: 'OK',
      icon: Icons.error,
      iconColor: Colors.red,
      btnColor: Colors.black,
    );
  }
}

Future<void> _showMaterialInputDialog(
    BuildContext context, int itemId, String materialName, double amount, double qty) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return MaterialInputDialog(
        itemId: itemId,
        materialName: materialName,
        amount: amount,
        qty: qty,
      );
    },
  );
}