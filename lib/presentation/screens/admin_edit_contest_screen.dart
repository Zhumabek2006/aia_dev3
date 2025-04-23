import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminEditContestScreen extends StatefulWidget {
  const AdminEditContestScreen({super.key});

  @override
  State<AdminEditContestScreen> createState() => AdminEditContestScreenState();
}

class AdminEditContestScreenState extends State<AdminEditContestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _testTypeController = TextEditingController();
  final _dateController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String? _selectedTestType;
  List<String> _testTypes = [];

  @override
  void initState() {
    super.initState();
    _loadContest();
    _loadTestTypes();
  }

  Future<void> _loadContest() async {
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final contestId = data['contestId'] as String;
    final contestDoc = await _firestore.collection('contests').doc(contestId).get();
    final testTypeDoc = await _firestore
        .collection('test_types')
        .doc(contestDoc['test_type_id'])
        .get();
    setState(() {
      _selectedTestType = testTypeDoc['name'];
      _testTypeController.text = _selectedTestType!;
      _dateController.text = contestDoc['date'] ?? '';
    });
  }

  Future<void> _loadTestTypes() async {
    QuerySnapshot testTypesSnapshot = await _firestore.collection('test_types').get();
    setState(() {
      _testTypes = testTypesSnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> _updateContest() async {
    if (_formKey.currentState!.validate()) {
      final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final contestId = data['contestId'] as String;
      final testTypeDoc = await _firestore
          .collection('test_types')
          .where('name', isEqualTo: _selectedTestType)
          .get();
      final testTypeId = testTypeDoc.docs.first.id;
      final contextCopy = context; // Сохраняем BuildContext

      await _firestore.collection('contests').doc(contestId).update({
        'test_type_id': testTypeId,
        'date': _dateController.text,
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
      appBar: AppBar(title: const Text("Edit Contest")),
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
                text: "Update Contest",
                onPressed: _updateContest,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}