import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/list_item.dart';

class TrainingScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Training")),
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
                        .collection('study_materials')
                        .snapshots(),
                    builder: (context, matSnapshot) {
                      if (!matSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final materials = matSnapshot.data!.docs;
                      if (materials.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No study materials available."),
                        );
                      }
                      return Column(
                        children: materials.map((material) {
                          return ListItem(
                            title: material['title'],
                            onEdit: () {
                              // Пользователь не может редактировать, но может просмотреть содержимое
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(material['title']),
                                  content: SingleChildScrollView(
                                    child: Text(material['content']),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDelete: () {}, // У пользователя нет прав на удаление
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Training"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Contests"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Results"),
        ],
        currentIndex: 0, // Индекс текущего экрана (Training)
        onTap: (index) {
          switch (index) {
            case 0:
              break; // Уже на этом экране
            case 1:
              context.go('/contests');
              break;
            case 2:
              context.go('/history');
              break;
            case 3:
              context.go('/settings');
              break;
            case 4:
              context.go('/results');
              break;
          }
        },
      ),
    );
  }
}