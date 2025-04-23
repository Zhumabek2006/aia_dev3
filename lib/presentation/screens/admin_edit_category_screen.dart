import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminEditCategoryScreen extends StatefulWidget {
  const AdminEditCategoryScreen({super.key});

  @override
  State<AdminEditCategoryScreen> createState() => AdminEditCategoryScreenState();
}

class AdminEditCategoryScreenState extends State<AdminEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _pointsController = TextEditingController();
  final List<String> _languages = ['ru', 'en'];
  final List<String> _selectedLanguages = [];
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final testTypeId = data['testTypeId'] as String;
    final categoryId = data['categoryId'] as String;
    final categoryDoc = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .doc(categoryId)
        .get();
    setState(() {
      _nameController.text = categoryDoc['name'] ?? '';
      _durationController.text = categoryDoc['duration'] ?? '';
      _pointsController.text = (categoryDoc['points_per_question'] ?? 1).toString();
      _selectedLanguages.clear();
      _selectedLanguages.addAll(List<String>.from(categoryDoc['languages'] ?? []));
    });
  }

  Future<void> _updateCategory() async {
    if (_formKey.currentState!.validate()) {
      final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final testTypeId = data['testTypeId'] as String;
      final categoryId = data['categoryId'] as String;
      final contextCopy = context; // Сохраняем BuildContext

      await _firestore.collection('test_types').doc(testTypeId).collection('categories').doc(categoryId).update({
        'name': _nameController.text,
        'duration': _durationController.text,
        'languages': _selectedLanguages,
        'points_per_question': int.parse(_pointsController.text),
      });

      if (contextCopy.mounted) {
        contextCopy.go('/admin');
      }
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
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Category")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _nameController,
                  labelText: "Category Name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter category name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _durationController,
                  labelText: "Duration (e.g., 1h)",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter duration";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _pointsController,
                  labelText: "Points per Question",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter points per question";
                    }
                    if (int.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text("Select Languages", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ..._languages.map((language) => CheckboxListTile(
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
                )),
                const SizedBox(height: 16),
                CustomButton(
                  text: "Update Category",
                  onPressed: _updateCategory,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}