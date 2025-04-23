import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ResultsScreen extends StatefulWidget {
  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<String> _testTypes = [];
  List<String> _categories = [];
  String? _selectedTestType;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadTestTypes();
  }

  Future<void> _loadTestTypes() async {
    QuerySnapshot testTypesSnapshot = await _firestore.collection('test_types').get();
    setState(() {
      _testTypes = testTypesSnapshot.docs.map((doc) => doc['name'] as String).toList();
      _testTypes.insert(0, "All"); // Добавляем опцию "Все" для фильтра
      _selectedTestType = "All";
    });
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    QuerySnapshot testTypesSnapshot = await _firestore.collection('test_types').get();
    Set<String> categoriesSet = {};
    for (var testType in testTypesSnapshot.docs) {
      QuerySnapshot categoriesSnapshot = await _firestore
          .collection('test_types')
          .doc(testType.id)
          .collection('categories')
          .get();
      categoriesSet.addAll(categoriesSnapshot.docs.map((doc) => doc['name'] as String));
    }
    setState(() {
      _categories = categoriesSet.toList();
      _categories.insert(0, "All"); // Добавляем опцию "Все" для фильтра
      _selectedCategory = "All";
    });
  }

  String _formatDate(String date) {
    final dateTime = DateTime.parse(date);
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Results")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  value: _selectedTestType,
                  hint: const Text("Select Test Type"),
                  isExpanded: true,
                  items: _testTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTestType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Text("Select Category"),
                  isExpanded: true,
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user!.uid)
                  .collection('test_history')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final tests = snapshot.data!.docs;

                // Фильтрация тестов
                var filteredTests = tests.where((test) {
                  bool matchesTestType = _selectedTestType == "All" || test['test_type'] == _selectedTestType;
                  bool matchesCategory = _selectedCategory == "All" || test['category'] == _selectedCategory;
                  return matchesTestType && matchesCategory;
                }).toList();

                if (filteredTests.isEmpty) {
                  return const Center(child: Text("No test results available."));
                }

                // Рассчитываем статистику
                int totalTests = filteredTests.length;
                double totalCorrectAnswers = 0;
                double totalQuestions = 0;
                int totalPoints = 0;

                for (var test in filteredTests) {
                  totalCorrectAnswers += test['correct_answers'] as int;
                  totalQuestions += test['total_questions'] as int;
                  totalPoints += test['points'] as int;
                }

                double averageCorrectPercentage = totalQuestions > 0 ? (totalCorrectAnswers / totalQuestions) * 100 : 0;
                double averagePoints = totalTests > 0 ? totalPoints / totalTests : 0;

                // Собираем данные для графика (баллы по датам)
                Map<String, int> pointsByDate = {};
                for (var test in filteredTests) {
                  String date = _formatDate(test['date']);
                  pointsByDate[date] = (pointsByDate[date] ?? 0) + (test['points'] as int);
                }

                return Column(
                  children: [
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
                                "Overall Statistics",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text("Total Tests: $totalTests"),
                              Text("Average Correct: ${averageCorrectPercentage.toStringAsFixed(1)}%"),
                              Text("Average Points: ${averagePoints.toStringAsFixed(1)}"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Text(
                        "Points by Date",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: pointsByDate.entries.map((entry) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text("${entry.value} points"),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredTests.length,
                        itemBuilder: (context, index) {
                          final test = filteredTests[index];
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
                  ],
                );
              },
            ),
          ),
        ],
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
        currentIndex: 4, // Индекс текущего экрана (Results)
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
              break; // Уже на этом экране
          }
        },
      ),
    );
  }
}