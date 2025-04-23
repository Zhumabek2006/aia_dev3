import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminEditQuestionScreen extends StatefulWidget {
  const AdminEditQuestionScreen({super.key});

  @override
  State<AdminEditQuestionScreen> createState() => AdminEditQuestionScreenState();
}

class AdminEditQuestionScreenState extends State<AdminEditQuestionScreen> {
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
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final testTypeId = data['testTypeId'] as String;
    final categoryId = data['categoryId'] as String;
    final questionId = data['questionId'] as String;
    final categoryDoc = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .doc(categoryId)
        .get();
    final questionDoc = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .doc(categoryId)
        .collection('questions')
        .doc(questionId)
        .get();
    setState(() {
      _languages = List<String>.from(categoryDoc['languages'] ?? []);
      _selectedLanguage = questionDoc['language'];
      _textController.text = questionDoc['text'] ?? '';
      final options = List<String>.from(questionDoc['options'] ?? []);
      for (int i = 0; i < 4; i++) {
        _optionsController[i].text = options.length > i ? options[i] : '';
      }
      _correctAnswerController.text = (questionDoc['correct_answer'] ?? 0).toString();
    });
  }

  Future<void> _updateQuestion() async {
    if (_formKey.currentState!.validate()) {
      final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final testTypeId = data['testTypeId'] as String;
      final categoryId = data['categoryId'] as String;
      final questionId = data['questionId'] as String;
      final contextCopy = context; // Сохраняем BuildContext

      await _firestore
          .collection('test_types')
          .doc(testTypeId)
          .collection('categories')
          .doc(categoryId)
          .collection('questions')
          .doc(questionId)
          .update({
        'language': _selectedLanguage,
        'text': _textController.text,
        'options': _optionsController.map((controller) => controller.text).toList(),
        'correct_answer': int.parse(_correctAnswerController.text),
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
      appBar: AppBar(title: const Text("Edit Question")),
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
                  text: "Update Question",
                  onPressed: _updateQuestion,
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