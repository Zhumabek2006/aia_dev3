import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminAddTestTypeScreen extends StatefulWidget {
  @override
  _AdminAddTestTypeScreenState createState() => _AdminAddTestTypeScreenState();
}

class _AdminAddTestTypeScreenState extends State<AdminAddTestTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  Future<void> _addTestType() async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('test_types').add({
        'name': _nameController.text.trim(),
        'created_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      });
      context.go('/admin');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Test Type")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: "Test Type Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a test type name";
                  }
                  return null;
                },
              ),
              CustomButton(
                text: "Add Test Type",
                onPressed: _addTestType,
              ),
            ],
          ),
        ),
      ),
    );
  }
}