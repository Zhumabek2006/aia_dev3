import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminAddTestTypeScreen extends StatefulWidget {
  const AdminAddTestTypeScreen({super.key});

  @override
  State<AdminAddTestTypeScreen> createState() => AdminAddTestTypeScreenState();
}

class AdminAddTestTypeScreenState extends State<AdminAddTestTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> _addTestType() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      final contextCopy = context; // Сохраняем BuildContext

      await _firestore.collection('test_types').add({
        'name': _nameController.text,
        'created_by': user!.uid,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (contextCopy.mounted) {
        contextCopy.go('/admin');
      }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: "Test Type Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter test type name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Add Test Type",
                onPressed: _addTestType,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}