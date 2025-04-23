import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminEditTestTypeScreen extends StatefulWidget {
  @override
  _AdminEditTestTypeScreenState createState() => _AdminEditTestTypeScreenState();
}

class _AdminEditTestTypeScreenState extends State<AdminEditTestTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateTestType(String id) async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('test_types').doc(id).update({
        'name': _nameController.text.trim(),
      });
      context.go('/admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String id = data['id'];
    _nameController.text = data['name'];

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Test Type")),
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
                text: "Update Test Type",
                onPressed: () => _updateTestType(id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}