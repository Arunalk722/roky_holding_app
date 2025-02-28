import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roky_holding/md_01/account_setup.dart';
import 'package:roky_holding/md_02/permission_management.dart';
import 'package:roky_holding/md_03/location_management.dart';
import 'package:roky_holding/md_03/location_wise_estimation.dart';
import 'package:roky_holding/md_03/material_create.dart';
import 'package:roky_holding/md_03/project_management.dart';
import 'package:roky_holding/md_04/location_payment_request_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Boolean values for permissions (all set to true for now)
  final List<bool> tilePermissions = [
    true,  // Permission Management
    true,  // Project Management
    true,  // Location Management
    true,  // Location Wise Estimation
    true,  // Material Create
    true,  // Payment Request
    true,  // Additional feature 1
    true,  // Additional feature 2
    true,  // Additional feature 3
    true,  // Additional feature 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
           // image: AssetImage("image/home_background.png"),
            image: NetworkImage('https://www.pixelstalk.net/wp-content/uploads/2016/08/Background-Full-HD-Images.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: tilePermissions.length,
                  itemBuilder: (context, index) {
                    // Only show tiles with permission set to true
                    if (!tilePermissions[index]) return const SizedBox.shrink();

                    return GestureDetector(
                      onTap: () {
                        switch (index) {
                          case 0:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PermissionManagementPage()));
                            break;
                          case 1:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProjectManagementScreen()));
                            break;
                          case 2:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LocationManagement()));
                            break;
                          case 3:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LocationCostCreate()));
                            break;
                          case 4:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MaterialCreate()));
                            break;
                          case 5:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProjectsPaymentRequestForm()));
                            break;
                          case 6:
                          case 7:
                          case 8:
                          case 9:
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Feature $index coming soon!")));
                            break;
                        }
                      },
                      child: Card(
                        elevation: 6,
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              index == 0
                                  ? FontAwesomeIcons.userShield
                                  : index == 1
                                  ? FontAwesomeIcons.diagramProject
                                  : index == 2
                                  ? FontAwesomeIcons.mapLocation
                                  : index == 3
                                  ? FontAwesomeIcons.moneyBill
                                  : index == 4
                                  ? FontAwesomeIcons.boxesStacked
                                  : index == 5
                                  ? FontAwesomeIcons.fileInvoice
                                  : FontAwesomeIcons.gear,
                              size: 40,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              index == 0
                                  ? 'Permission Manage'
                                  : index == 1
                                  ? 'Project Management'
                                  : index == 2
                                  ? 'Location Management'
                                  : index == 3
                                  ? 'Project Cost'
                                  : index == 4
                                  ? 'Material Create'
                                  : index == 5
                                  ? 'Payment Request'
                                  : 'Feature $index',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
