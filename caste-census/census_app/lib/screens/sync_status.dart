import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';
import '../models/census_model.dart';

class SyncStatus extends StatefulWidget {
  @override
  _SyncStatusState createState() => _SyncStatusState();
}

class _SyncStatusState extends State<SyncStatus> {
  String _status = "Ready to Sync";
  bool _isSyncing = false;

  void _syncData() async {
    setState(() {
      _isSyncing = true;
      _status = "Syncing...";
    });

    final db = await LocalDbService.database;
    final records = await db.query('census', where: "status = ?", whereArgs: ["PENDING"]);

    if (records.isEmpty) {
      setState(() {
        _status = "No records to sync.";
        _isSyncing = false;
      });
      return;
    }

    int successCount = 0;
    for (var r in records) {
      final model = CensusModel(
        householdId: r['householdId'] as String,
        caste: r['caste'] as String,
        education: r['education'] as String,
        occupation: r['occupation'] as String,
        income: r['income'] as int,
        region: r['region'] as String,
        profileImageBase64: r['profileImageBase64'] as String?,
      );

      bool success = await ApiService.submitCensus(model);

      if (success) {
        await db.update('census', {'status': 'SYNCED'}, where: 'id = ?', whereArgs: [r['id']]);
        successCount++;
      }
    }

    setState(() {
      _status = "Synced $successCount records!";
      _isSyncing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sync Data")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            _isSyncing 
              ? CircularProgressIndicator()
              : ElevatedButton(onPressed: _syncData, child: Text("Sync Now"))
          ],
        ),
      ),
    );
  }
}