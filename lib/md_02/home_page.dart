import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roky_holding/md_01/account_setup.dart';
import 'package:roky_holding/md_02/permission_management.dart';
import 'package:roky_holding/md_03/location_management.dart';
import 'package:roky_holding/md_03/location_wise_estimation.dart';
import 'package:roky_holding/md_03/project_management.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        backgroundColor: Color(0xFF3D5AFE),  // Rich blue color for the app bar
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Adjust the number of items per row based on available space
              int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              double itemHeight = constraints.maxHeight / 4; // Dynamic height

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: 8,  // Number of tiles
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate based on the index
                      switch (index) {
                        case 0:
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PermissionManagementPage()));
                          break;
                        case 1:
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectManagementScreen()));
                          break;
                        case 2:
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LocationCostCreate()));
                          break;
                        case 3:
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LocationManagement()));

                          break;
                        case 4:
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSetupPage()));
                          break;
                      }
                    },
                    child: Card(
                      elevation: 6,
                      color: Color(0xFF1976D2),  // Deep blue for cards, maintaining contrast
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            index == 0
                                ? FontAwesomeIcons.lockOpen
                                : index == 1
                                ? FontAwesomeIcons.penToSquare
                                : index == 2
                                ? FontAwesomeIcons.locationArrow
                                : index == 3
                                ? FontAwesomeIcons.house
                                : index == 4
                                ? FontAwesomeIcons.penToSquare
                                : index == 5
                                ? Icons.work
                                : FontAwesomeIcons.cogs,
                            size: 40,
                            color: Colors.white,  // Icon color set to white for better contrast
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
                                ? 'Project Cost Management'
                                : index == 4
                                ? 'Index 4'
                                : 'Account Setup',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,  // Font size adjusted for better balance
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
    );
  }
}
