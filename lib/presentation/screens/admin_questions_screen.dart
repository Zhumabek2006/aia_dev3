import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_button.dart';
import '../widgets/list_item.dart';

class AdminQuestionsScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _deleteQuestion(String testTypeId, String categoryId, String questionId) async {
    await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .doc(categoryId)
        .collection('questions')
        .doc(questionId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('test_types').snapshots(),
        builder: (context, testSnapshot) {
          if (!testSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final testTypes = testSnapshot.data!.docs;
          return ListView.builder(
            itemCount: testTypes.length,
            itemBuilder: (context, testIndex) {
              final testType = testTypes[testIndex];
              return ExpansionTile(
                title: Text(testType['name']),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('test_types')
                        .doc(testType.id)
                        .collection('categories')
                        .snapshots(),
                    builder: (context, catSnapshot) {
                      if (!catSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final categories = catSnapshot.data!.docs;
                      return Column(
                        children: categories.map((category) {
                          return ExpansionTile(
                            title: Text(category['name']),
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: _firestore
                                    .collection('test_types')
                                    .doc(testType.id)
                                    .collection('categories')
                                    .doc(category.id)
                                    .collection('questions')
                                    .snapshots(),
                                builder: (context, qSnapshot) {
                                  if (!qSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                                  final questions = qSnapshot.data!.docs;
                                  return Column(
                                    children: questions.map((question) {
                                      return ListItem(
                                        title: "${question['text']} (${question['language']})",
                                        onEdit: () {
                                          context.go('/admin/edit-question', extra: {
                                            'testTypeId': testType.id,
                                            'categoryId': category.id,
                                            'questionId': question.id,
                                            'text': question['text'],
                                            'options': question['options'],
                                            'correctAnswer': question['correct_answer'],
                                            'language': question['language'],
                                            'order': question['order'],
                                          });
                                        },
                                        onDelete: () => _deleteQuestion(testType.id, category.id, question.id),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                              CustomButton(
                                text: "Add Question to ${category['name']}",
                                onPressed: () {
                                  context.go('/admin/add-question', extra: {
                                    'testTypeId': testType.id,
                                    'categoryId': category.id,
                                    'languages': category['languages'],
                                  });
                                },
                                color: Colors.green,
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}