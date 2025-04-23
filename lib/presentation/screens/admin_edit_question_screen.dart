import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminEditQuestionScreen extends StatefulWidget {
  @override
  _AdminEditQuestionScreenState createState() => _AdminEditQuestionScreenState();
}

class _AdminEditQuestionScreenState extends State<AdminEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _orderController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String? _selectedLanguage;
  int? _correctAnswer;

  Future<void> _updateQuestion(String testTypeId, String categoryId, String questionId) async {
    if (_formKey.currentState!.validate() && _selectedLanguage != null && _correctAnswer != null) {
      await _firestore
          .collection('test_types')
          .doc(testTypeId)
          .collection('categories')
          .doc(categoryId)
          .collection('questions')
          .doc(questionId)
          .update({
        'text': _textController.text.trim(),
        'options': [
          _option1Controller.text.trim(),
          _option2Controller.text.trim(),
          _option3Controller.text.trim(),
          _option4Controller.text.trim(),
        ],
        'correct_answer': _correctAnswer,
        'language': _selectedLanguage,
        'order': int.parse(_orderController.text.trim()),
      });
      context.go('/admin');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String testTypeId = data['testTypeId'];
    final String categoryId = data['categoryId'];
    final String questionId = data['questionId'];
    _textController.text = data['text'];
    _option1Controller.text = data['options'][0];
    _option2Controller.text = data['options'][1];
    _option3Controller.text = data['options'][2];
    _option4Controller.text = data['options'][3];
    _orderController.text = data['order'].toString();
    _selectedLanguage = data['language'];
    _correctAnswer = data['correctAnswer'];

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Question")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  controller: _textController,
                  labelText: "Question Text",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the question text";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _option1Controller,
                  labelText: "Option 1",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter option 1";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _option2Controller,
                  labelText: "Option 2",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter option 2";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _option3Controller,
                  labelText: "Option 3",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter option 3";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _option4Controller,
                  labelText: "Option 4",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter option 4";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _orderController,
                  labelText: "Order",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the order";
                    }
                    if (int.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text("Language: $_selectedLanguage", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Text("Select Correct Answer", style: TextStyle(fontSize: 16)),
                ...List.generate(4, (index) {
                  return RadioListTile<int>(
                    title: Text("Option ${index + 1}"),
                    value: index,
                    groupValue: _correctAnswer,
                    onChanged: (value) {
                      setState(() {
                        _correctAnswer = value;
                      });
                    },
                  );
                }),
                CustomButton(
                  text: "Update Question",
                  onPressed: () => _updateQuestion(testTypeId, categoryId, questionId),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}