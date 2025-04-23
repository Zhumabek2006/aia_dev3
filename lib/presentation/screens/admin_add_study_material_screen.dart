import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminAddStudyMaterialScreen extends StatefulWidget {
  const AdminAddStudyMaterialScreen({super.key});

  @override
  State<AdminAddStudyMaterialScreen> createState() => AdminAddStudyMaterialScreenState();
}

class AdminAddStudyMaterialScreenState extends State<AdminAddStudyMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> _addStudyMaterial() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final testTypeId = data['testTypeId'] as String;
      final contextCopy = context; // Сохраняем BuildContext

      await _firestore.collection('test_types').doc(testTypeId).collection('study_materials').add({
        'title': _titleController.text,
        'content': _contentController.text,
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
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Study Material")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: "Title",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter title";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contentController,
                labelText: "Content",
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter content";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Add Study Material",
                onPressed: _addStudyMaterial,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}