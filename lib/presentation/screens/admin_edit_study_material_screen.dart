import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminEditStudyMaterialScreen extends StatefulWidget {
  const AdminEditStudyMaterialScreen({super.key});
  @override
  _AdminEditStudyMaterialScreenState createState() => _AdminEditStudyMaterialScreenState();
}

class _AdminEditStudyMaterialScreenState extends State<AdminEditStudyMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  Future<void> _updateStudyMaterial(String testTypeId, String materialId) async {
    if (_formKey.currentState!.validate()) {
      await _firestore
          .collection('test_types')
          .doc(testTypeId)
          .collection('study_materials')
          .doc(materialId)
          .update({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
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
    final String materialId = data['materialId'];
    _titleController.text = data['title'];
    _contentController.text = data['content'];

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Study Material")),
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
                text: "Update Study Material",
                onPressed: () => _updateStudyMaterial(testTypeId, materialId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}