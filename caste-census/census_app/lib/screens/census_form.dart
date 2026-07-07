import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/census_model.dart';
import '../services/local_db_service.dart';
import 'sync_status.dart';

class CensusForm extends StatefulWidget {
  @override
  _CensusFormState createState() => _CensusFormState();
}

class _CensusFormState extends State<CensusForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Data
  String? householdId, caste, education, occupation, region;
  int? income;
  String? _base64Image;
  File? _imageFile;

  // PICK IMAGE (WINDOWS SAFE)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // On Windows, use Gallery. On Phone, use Camera.
    final source = Platform.isWindows ? ImageSource.gallery : ImageSource.camera;

    final pickedFile = await picker.pickImage(source: source, maxWidth: 600);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _imageFile = File(pickedFile.path);
        _base64Image = base64Encode(bytes);
      });
    }
  }

  void _saveOffline() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final model = CensusModel(
        householdId: householdId!,
        caste: caste!,
        education: education!,
        occupation: occupation!,
        income: income!,
        region: region!,
        profileImageBase64: _base64Image,
      );

      final db = await LocalDbService.database;
      await db.insert('census', model.toMap());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved Offline!")));
      _formKey.currentState!.reset();
      setState(() {
        _imageFile = null;
        _base64Image = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Census Form"),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SyncStatus())),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                color: Colors.grey[300],
                child: _imageFile == null
                    ? Center(child: Icon(Icons.camera_alt, size: 50))
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: "Household ID"),
              onSaved: (v) => householdId = v,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Caste"),
              onSaved: (v) => caste = v,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Education"),
              onSaved: (v) => education = v,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Occupation"),
              onSaved: (v) => occupation = v,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Income"),
              keyboardType: TextInputType.number,
              onSaved: (v) => income = int.parse(v!),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Region"),
              onSaved: (v) => region = v,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveOffline,
              child: Text("Save Offline"),
            ),
          ],
        ),
      ),
    );
  }
}