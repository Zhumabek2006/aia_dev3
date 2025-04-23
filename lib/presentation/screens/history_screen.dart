import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _formatDate(String date) {
    final dateTime = DateTime.parse(date);
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('test_history')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final tests = snapshot.data!.docs;
          if (tests.isEmpty) {
            return const Center(child: Text("No test history available."));
          }

          // Рассчитываем общий итог
          int totalCorrectAnswers = 0;
          int totalQuestions = 0;
          int totalPoints = 0;
          int totalTimeSpent = 0;
          int totalTime = 0;

          for (var test in tests) {
            totalCorrectAnswers += test['correct_answers'] as int;
            totalQuestions += test['total_questions'] as int;
            totalPoints += test['points'] as int;
            totalTimeSpent += test['time_spent'] as int;
            totalTime += test['total_time'] as int;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: ListTile(
                        title: Text("${test['test_type']} - ${test['category']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${_formatDate(test['date'])}"),
                            Text("Score: ${test['correct_answers']}/${test['total_questions']}"),
                            Text("Points: ${test['points']}"),
                            Text("Time: ${test['time_spent']} min/${test['total_time']} min"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Summary",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text("Total Correct: $totalCorrectAnswers/$totalQuestions"),
                        Text("Total Points: $totalPoints"),
                        Text("Total Time: $totalTimeSpent min/$totalTime min"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/training');
              break;
            case 1:
              context.go('/contests');
              break;
            case 2:
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