import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminAddContestScreen extends StatefulWidget {
  @override
  _AdminAddContestScreenState createState() => _AdminAddContestScreenState();
}

class _AdminAddContestScreenState extends State<AdminAddContestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String? _selectedTestTypeId;
  List<String> _testTypes = [];
  List<String> _testTypeIds = [];

  @override
  void initState() {
    super.initState();
    _loadTestTypes();
  }

  Future<void> _loadTestTypes() async {
    final testTypesSnapshot = await _firestore.collection('test_types').get();
    setState(() {
      _testTypes = testTypesSnapshot.docs.map((doc) => doc['name'] as String).toList();
      _testTypeIds = testTypesSnapshot.docs.map((doc) => doc.id).toList();
      if (_testTypes.isNotEmpty) {
        _selectedTestTypeId = _testTypeIds.first;
      }
    });
  }

  Future<void> _addContest() async {
    if (_formKey.currentState!.validate() && _selectedTestTypeId != null) {
      await _firestore.collection('contests').add({
        'test_type_id': _selectedTestTypeId,
        'date': _dateController.text.trim(),
        'created_by': 'admin',
        'participants': [],
      });
      context.go('/admin');
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Contest")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButton<String>(
                value: _selectedTestTypeId,
                hint: const Text("Select Test Type"),
                isExpanded: true,
                items: _testTypeIds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final id = entry.value;
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(_testTypes[index]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTestTypeId = value;
                  });
                },
              ),
              CustomTextField(
                controller: _dateController,
                labelText: "Date (e.g., 2025-05-25T10:00:00Z)",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a date";
                  }
                  return null;
                },
              ),
              CustomButton(
                text: "Add Contest",
                onPressed: _addContest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}