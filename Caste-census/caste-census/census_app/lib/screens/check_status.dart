import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckStatus extends StatefulWidget {
  @override
  _CheckStatusState createState() => _CheckStatusState();
}

class _CheckStatusState extends State<CheckStatus> {
  final _idController = TextEditingController();
  String? _status;
  List<dynamic> _schemes = [];
  bool _loading = false;
  Map<String, dynamic>? _data;

  void _check() async {
    setState(() { _loading = true; _status = null; _data = null; _schemes = []; });

    try {
      // Call your new Java Endpoint
      final res = await http.get(Uri.parse("http://localhost:9090/api/census/status/${_idController.text}"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _data = data;
          _status = data['verificationStatus'];
          
          // Simple Client-Side Scheme Logic (Matching your Admin Dashboard)
          int income = data['income'];
          String occupation = data['occupation'];
          
          if (income < 50000) {
             _schemes.add("🏠 PM Awas Yojana");
             _schemes.add("🏥 Ayushman Bharat");
          }
          if (income < 100000 && occupation.toString().toLowerCase().contains("student")) {
             _schemes.add("🎓 National Scholarship");
          }
          if (_schemes.isEmpty) _schemes.add("No Schemes Eligible");
        });
      } else {
        setState(() => _status = "NOT_FOUND");
      }
    } catch (e) {
      setState(() => _status = "ERROR");
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Public Status Portal")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: "Enter Household ID", 
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _check,
                )
              ),
            ),
            SizedBox(height: 20),
            
            if (_loading) CircularProgressIndicator(),

            if (_status == "NOT_FOUND") 
              Text("❌ No record found for this ID.", style: TextStyle(color: Colors.red, fontSize: 18)),

            if (_data != null) ...[
              Card(
                elevation: 4,
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Status: $_status", 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, 
                        color: _status == "VERIFIED" ? Colors.green : (_status == "FLAGGED" ? Colors.red : Colors.orange))
                      ),
                      SizedBox(height: 10),
                      Text("Income: ₹${_data!['income']}", style: TextStyle(fontSize: 18)),
                      Divider(),
                      Text("Eligible Schemes:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ..._schemes.map((s) => ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text(s),
                      ))
                    ],
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}