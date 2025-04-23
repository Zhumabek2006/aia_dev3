import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminAddContestScreen extends StatefulWidget {
  const AdminAddContestScreen({super.key});

  @override
  State<AdminAddContestScreen> createState() => AdminAddContestScreenState();
}

class AdminAddContestScreenState extends State<AdminAddContestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _testTypeController = TextEditingController();
  final _dateController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String? _selectedTestType;
  List<String> _testTypes = [];

  @override
  void initState() {
    super.initState();
    _loadTestTypes();
  }

  Future<void> _loadTestTypes() async {
    QuerySnapshot testTypesSnapshot = await _firestore.collection('test_types').get();
    setState(() {
      _testTypes = testTypesSnapshot.docs.map((doc) => doc['name'] as String).toList();
      if (_testTypes.isNotEmpty) {
        _selectedTestType = _testTypes.first;
        _testTypeController.text = _selectedTestType!;
      }
    });
  }

  Future<void> _addContest() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      final testTypeDoc = await _firestore
          .collection('test_types')
          .where('name', isEqualTo: _selectedTestType)
          .get();
      final testTypeId = testTypeDoc.docs.first.id;
      final contextCopy = context; // Сохраняем BuildContext

      await _firestore.collection('contests').add({
        'test_type_id': testTypeId,
        'date': _dateController.text,
        'created_by': user!.uid,
        'participants': [],
      });

      if (contextCopy.mounted) {
        contextCopy.go('/admin');
      }
    }
  }

  @override
  void dispose() {
    _testTypeController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Test Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedTestType,
                hint: const Text("Select Test Type"),
                isExpanded: true,
                items: _testTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTestType = value;
                    _testTypeController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _dateController,
                labelText: "Date (e.g., 2025-04-22T10:00:00Z)",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter date";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Add Contest",
                onPressed: _addContest,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}