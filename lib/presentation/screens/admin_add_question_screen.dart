import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminAddQuestionScreen extends StatefulWidget {
  const AdminAddQuestionScreen({super.key});

  @override
  State<AdminAddQuestionScreen> createState() => AdminAddQuestionScreenState();
}

class AdminAddQuestionScreenState extends State<AdminAddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _optionsController = List.generate(4, (_) => TextEditingController());
  final _correctAnswerController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String? _selectedLanguage;
  List<String> _languages = [];

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
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
      _languages = List<String>.from(categoryDoc['languages'] ?? []);
      if (_languages.isNotEmpty) {
        _selectedLanguage = _languages.first;
      }
    });
  }

  Future<void> _addQuestion() async {
    if (_formKey.currentState!.validate()) {
      final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final testTypeId = data['testTypeId'] as String;
      final categoryId = data['categoryId'] as String;
      final contextCopy = context; // Сохраняем BuildContext

      final questionsSnapshot = await _firestore
          .collection('test_types')
          .doc(testTypeId)
          .collection('categories')
          .doc(categoryId)
          .collection('questions')
          .get();

      await _firestore
          .collection('test_types')
          .doc(testTypeId)
          .collection('categories')
          .doc(categoryId)
          .collection('questions')
          .add({
        'language': _selectedLanguage,
        'text': _textController.text,
        'options': _optionsController.map((controller) => controller.text).toList(),
        'correct_answer': int.parse(_correctAnswerController.text),
        'order': questionsSnapshot.docs.length + 1,
      });

      if (contextCopy.mounted) {
        contextCopy.go('/admin');
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    for (var controller in _optionsController) {
      controller.dispose();
    }
    _correctAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Question")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Language", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  hint: const Text("Select Language"),
                  isExpanded: true,
                  items: _languages.map((language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _textController,
                  labelText: "Question Text",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter question text";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CustomTextField(
                      controller: _optionsController[index],
                      labelText: "Option ${index + 1}",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter option ${index + 1}";
                        }
                        return null;
                      },
                    ),
                  );
                }),
                CustomTextField(
                  controller: _correctAnswerController,
                  labelText: "Correct Answer Index (0-3)",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter correct answer index";
                    }
                    final index = int.tryParse(value);
                    if (index == null || index < 0 || index > 3) {
                      return "Please enter a valid index (0-3)";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: "Add Question",
                  onPressed: _addQuestion,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}