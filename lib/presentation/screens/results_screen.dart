import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => ResultsScreenState();
}

class ResultsScreenState extends State<ResultsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _formatDate(String date) {
    final dateTime = DateTime.parse(date);
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    // Проверяем, авторизован ли пользователь
    if (user == null) {
      // Если пользователь не авторизован, перенаправляем на экран логина
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Results")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('contests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final contests = snapshot.data!.docs;
          final completedContests = contests.where((contest) {
            final participants = List<String>.from(contest['participants'] ?? []);
            return participants.contains(user.uid);
          }).toList();

          return ListView.builder(
            itemCount: completedContests.length,
            itemBuilder: (context, index) {
              final contest = completedContests[index];
              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('contests')
                    .doc(contest.id)
                    .collection('contest_results')
                    .orderBy('points', descending: true)
                    .snapshots(),
                builder: (context, resultSnapshot) {
                  if (!resultSnapshot.hasData) return const SizedBox.shrink();
                  final results = resultSnapshot.data!.docs;
                  final userResult = results.firstWhere(
                    (result) => result['user_id'] == user.uid,
                    orElse: () => results.first,
                  );
                  final userRank = results.indexWhere((result) => result['user_id'] == user.uid) + 1;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: ExpansionTile(
                      title: Text("Contest: ${userResult['test_type']}"),
                      subtitle: Text("Rank: $userRank, Points: ${userResult['points']}"),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Category: ${userResult['category']}"),
                              Text("Correct Answers: ${userResult['correct_answers']}/${userResult['total_questions']}"),
                              Text("Time Spent: ${userResult['time_spent']} min"),
                              Text("Date: ${_formatDate(userResult['date'])}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/training');
              break;
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
              break;
          }
        },
      ),
    );
  }
}