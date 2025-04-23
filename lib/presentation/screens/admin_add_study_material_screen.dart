import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminAddStudyMaterialScreen extends StatefulWidget {
  @override
  _AdminAddStudyMaterialScreenState createState() => _AdminAddStudyMaterialScreenState();
}

class _AdminAddStudyMaterialScreenState extends State<AdminAddStudyMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  Future<void> _addStudyMaterial(String testTypeId) async {
    if (_formKey.currentState!.validate()) {
      await _firestore
          .collection('test_types')
          .doc(testTypeId)
          .collection('study_materials')
          .add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'created_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      });
      context.go('/admin');
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
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String testTypeId = data['testTypeId'];

    return Scaffold(
      appBar: AppBar(title: const Text("Add Study Material")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: "Title",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a title";
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _contentController,
                labelText: "Content",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter content";
                  }
                  return null;
                },
              ),
              CustomButton(
                text: "Add Study Material",
                onPressed: () => _addStudyMaterial(testTypeId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}