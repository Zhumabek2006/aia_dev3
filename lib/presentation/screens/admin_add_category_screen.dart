import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminAddCategoryScreen extends StatefulWidget {
  @override
  _AdminAddCategoryScreenState createState() => _AdminAddCategoryScreenState();
}

class _AdminAddCategoryScreenState extends State<AdminAddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _pointsController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  List<String> _languages = ['ru', 'en', 'ky'];
  List<String> _selectedLanguages = [];

  Future<void> _addCategory(String testTypeId) async {
    if (_formKey.currentState!.validate()) {
      await _firestore
          .collection('test_types')
          .doc(testTypeId)
          .collection('categories')
          .add({
        'name': _nameController.text.trim(),
        'duration': _durationController.text.trim(),
        'languages': _selectedLanguages,
        'points_per_question': int.parse(_pointsController.text.trim()),
      });
      context.go('/admin');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String testTypeId = data['testTypeId'];

    return Scaffold(
      appBar: AppBar(title: const Text("Add Category")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  labelText: "Category Name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a category name";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _durationController,
                  labelText: "Duration (e.g., 1h)",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a duration";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _pointsController,
                  labelText: "Points per Question",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter points per question";
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text("Select Languages", style: TextStyle(fontSize: 16)),
                ..._languages.map((language) {
                  return CheckboxListTile(
                    title: Text(language),
                    value: _selectedLanguages.contains(language),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedLanguages.add(language);
                        } else {
                          _selectedLanguages.remove(language);
                        }
                      });
                    },
                  );
                }).toList(),
                CustomButton(
                  text: "Add Category",
                  onPressed: () => _addCategory(testTypeId),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}