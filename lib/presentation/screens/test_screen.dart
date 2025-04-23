import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => TestScreenState();
}

class TestScreenState extends State<TestScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int? _selectedOption;
  int _timeSpent = 0; // В минутах
  int _totalTime = 0; // В минутах
  int _remainingSeconds = 0; // Для таймера в секундах
  Timer? _timer;
  bool _isTimeUp = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final user = _auth.currentUser;
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final testTypeId = data['testTypeId'] as String;
    final categoryId = data['categoryId'] as String;
    final language = data['language'] as String;

    // Получаем использованные вопросы
    final usedQuestionsSnapshot = await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('used_questions')
        .where('test_type_id', isEqualTo: testTypeId)
        .where('category_id', isEqualTo: categoryId)
        .where('language', isEqualTo: language)
        .get();

    final usedQuestionIds = usedQuestionsSnapshot.docs
        .map((doc) => doc['question_id'] as String)
        .toList();

    // Получаем первые 30 вопросов
    final questionsSnapshot = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .doc(categoryId)
        .collection('questions')
        .where('language', isEqualTo: language)
        .where(FieldPath.documentId, whereNotIn: usedQuestionIds.isEmpty ? null : usedQuestionIds)
        .orderBy('order')
        .limit(30)
        .get();

    // Получаем общее время
    final categoryDoc = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .doc(categoryId)
        .get();

    final totalTime = _parseDuration(categoryDoc['duration'] ?? '1h');

    setState(() {
      _questions = questionsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'text': data['text'] as String,
          'options': List<String>.from(data['options']),
          'correct_answer': data['correct_answer'] as int,
        };
      }).toList();
      _totalTime = totalTime;
      _remainingSeconds = totalTime * 60; // В секундах
    });

    // Запускаем таймер
    _startTimer();

    // Добавляем вопросы в used_questions
    for (var question in _questions) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('used_questions')
          .add({
        'test_type_id': testTypeId,
        'category_id': categoryId,
        'language': language,
        'question_id': question['id'],
      });
    }
  }

  int _parseDuration(String duration) {
    final hours = int.parse(duration.replaceAll('h', ''));
    return hours * 60; // В минутах
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        setState(() {
          _isTimeUp = true;
        });
        timer.cancel();
        _saveTestResult();
        if (mounted) {
          context.go('/main');
        }
      } else {
        setState(() {
          _remainingSeconds--;
          _timeSpent = _totalTime - (_remainingSeconds ~/ 60); // Обновляем время, потраченное в минутах
        });
      }
    });
  }

  void _submitAnswer() {
    if (_selectedOption == null) return;

    if (_selectedOption == _questions[_currentQuestionIndex]['correct_answer']) {
      _correctAnswers++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
      });
    } else {
      _timer?.cancel();
      _saveTestResult();
      if (mounted) {
        context.go('/main');
      }
    }
  }

  Future<void> _saveTestResult() async {
    final user = _auth.currentUser;
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final testTypeId = data['testTypeId'] as String;
    final categoryId = data['categoryId'] as String;
    final testName = data['testName'] as String;
    final categoryName = data['categoryName'] as String;
    final contestId = data['contestId'] as String?;

    final categoryDoc = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .doc(categoryId)
        .get();

    final pointsPerQuestion = (categoryDoc['points_per_question'] ?? 1) as num;
    final points = (_correctAnswers * pointsPerQuestion).toInt();

    // Сохраняем результат в test_history
    await _firestore.collection('users').doc(user!.uid).collection('test_history').add({
      'date': DateTime.now().toIso8601String(),
      'test_type': testName,
      'category': categoryName,
      'correct_answers': _correctAnswers,
      'total_questions': _questions.length,
      'points': points,
      'time_spent': _timeSpent,
      'total_time': _totalTime,
    });

    // Если это тест в рамках контеста, сохраняем результат в contest_results
    if (contestId != null) {
      await _firestore.collection('contests').doc(contestId).collection('contest_results').add({
        'user_id': user.uid,
        'test_type': testName,
        'category': categoryName,
        'correct_answers': _correctAnswers,
        'total_questions': _questions.length,
        'points': points,
        'time_spent': _timeSpent,
        'total_time': _totalTime,
        'date': DateTime.now().toIso8601String(),
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Test completed! Score: $points")),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Test")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Scaffold(
      appBar: AppBar(
        title: Text("Test: ${currentQuestion['text']}"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Time Left: $minutes:${seconds.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${_currentQuestionIndex + 1}/${_questions.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(currentQuestion['text'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ...List.generate(currentQuestion['options'].length, (index) {
              return RadioListTile<int>(
                title: Text(currentQuestion['options'][index]),
                value: index,
                groupValue: _selectedOption,
                onChanged: _isTimeUp
                    ? null
                    : (value) {
                        setState(() {
                          _selectedOption = value;
                        });
                      },
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isTimeUp ? null : _submitAnswer,
              child: Text(_currentQuestionIndex < _questions.length - 1 ? "Next" : "Finish"),
            ),
          ],
        ),
      ),
    );
  }
}