import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'census_form.dart';
import 'check_status.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final role = await ApiService.login(_userController.text, _passController.text);
    setState(() => _isLoading = false);

    if (role == "ROLE_ENUMERATOR") {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => CensusForm())
      );
    } else if (role == "ROLE_ADMIN") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome Admin! (Dashboard coming soon)"))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid Credentials!"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Census Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _userController, decoration: InputDecoration(labelText: "Username")),
            TextField(controller: _passController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            _isLoading 
              ? CircularProgressIndicator()
              : ElevatedButton(onPressed: _login, child: Text("Login")),
            // ... inside the Column ...
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CheckStatus()));
              },
              child: Text("Check Application Status (Public)", style: TextStyle(fontSize: 16)),
            ),
              
          ],
          
        ),
      ),
    );
  }
}