import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:roky_holding/env/api_info.dart';
import 'package:roky_holding/env/print_debug.dart';

class AppVersionTile extends StatefulWidget {
  const AppVersionTile({Key? key}) : super(key: key);

  @override
  _apiVersionTileState createState() => _apiVersionTileState();
}

class _apiVersionTileState extends State<AppVersionTile> {
  String _apiVersion = "Fetching...";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadingAppVersion();
  }

  Future<void> _loadingAppVersion() async {
    setState(() => _isLoading = true);

    try {
       String reqUrl = '${APIHost().APIURL}/info.php';
      final response = await http.get(
        Uri.parse(reqUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        PD.pd(text: responseData.toString());

        if (responseData['status'] == 200) {
          setState(() {
            _apiVersion = responseData['BUILD_VERSION'] ?? "Unknown";
          });
        } else {
          setState(() {
            _apiVersion = responseData['message'] ?? "Error retrieving version";
          });
        }
      } else {
        setState(() => _apiVersion = "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _apiVersion = "Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.info, color: Colors.blueAccent),
        title: Text(
          'App Version',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Api: $_apiVersion\nApp: ${APIHost().AppVersion}',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        trailing: _isLoading
            ? CircularProgressIndicator()
            : IconButton(
          icon: Icon(Icons.refresh, color: Colors.blue),
          onPressed: _loadingAppVersion,
        ),
      ),
    );
  }
}
