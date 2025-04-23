import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminQuestionsScreen extends StatelessWidget {
  const AdminQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final testTypeId = data['testTypeId'] as String;
    final categoryId = data['categoryId'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Questions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go(
                '/admin/add-question',
                extra: {
                  'testTypeId': testTypeId,
                  'categoryId': categoryId,
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('test_types')
            .doc(testTypeId)
            .collection('categories')
            .doc(categoryId)
            .collection('questions')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final questions = snapshot.data!.docs;
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: ListTile(
                  title: Text(question['text']),
                  subtitle: Text("Language: ${question['language']}"),
                  onTap: () {
                    context.go(
                      '/admin/edit-question',
                      extra: {
                        'testTypeId': testTypeId,
                        'categoryId': categoryId,
                        'questionId': question.id,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}