import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_button.dart';
import '../widgets/list_item.dart';

class ContestsScreen extends StatefulWidget {
  @override
  _ContestsScreenState createState() => _ContestsScreenState();
}

class _ContestsScreenState extends State<ContestsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${message.notification!.title}: ${message.notification!.body}",
            ),
          ),
        );
      }
    });
  }

  Future<void> _initializeFCM() async {
    _fcmToken = await _messaging.getToken();
    final user = _auth.currentUser;
    if (user != null && _fcmToken != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcm_token': _fcmToken,
      });
    }
  }

  Future<String> _getTestTypeName(String testTypeId) async {
    final doc = await _firestore.collection('test_types').doc(testTypeId).get();
    return doc['name'] ?? 'Unknown Test';
  }

  Future<List<String>> _getCategoriesForTestType(String testTypeId) async {
    final categoriesSnapshot = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .get();
    return categoriesSnapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<String> _getFirstCategoryId(String testTypeId) async {
    final categoriesSnapshot = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .limit(1)
        .get();
    return categoriesSnapshot.docs.isNotEmpty ? categoriesSnapshot.docs.first.id : '';
  }

  Future<String> _getFirstLanguage(String testTypeId, String categoryId) async {
    final categoryDoc = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .doc(categoryId)
        .get();
    final languages = List<String>.from(categoryDoc['languages'] ?? []);
    return languages.isNotEmpty ? languages.first : 'ru';
  }

  Future<void> _joinContest(String contestId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('contests').doc(contestId).update({
        'participants': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  Future<void> _leaveContest(String contestId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('contests').doc(contestId).update({
        'participants': FieldValue.arrayRemove([user.uid]),
      });
    }
  }

  Future<void> _toggleNotifications(String contestId, bool enable) async {
    final user = _auth.currentUser;
    if (user != null) {
      if (enable) {
        await _firestore.collection('users').doc(user.uid).update({
          'subscribed_contests': FieldValue.arrayUnion([contestId]),
        });
      } else {
        await _firestore.collection('users').doc(user.uid).update({
          'subscribed_contests': FieldValue.arrayRemove([contestId]),
        });
      }
    }
  }

  Future<bool> _hasUserCompletedContest(String contestId, String userId) async {
    final resultSnapshot = await _firestore
        .collection('contests')
        .doc(contestId)
        .collection('contest_results')
        .where('user_id', isEqualTo: userId)
        .get();
    return resultSnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Contests")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(user!.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final subscribedContests = List<String>.from(userData['subscribed_contests'] ?? []);

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('contests').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final contests = snapshot.data!.docs;
              return ListView.builder(
                itemCount: contests.length,
                itemBuilder: (context, index) {
                  final contest = contests[index];
                  final participants = List<String>.from(contest['participants'] ?? []);
                  final isJoined = participants.contains(user.uid);
                  final isSubscribed = subscribedContests.contains(contest.id);
                  final contestDate = DateTime.parse(contest['date']);
                  final now = DateTime.now();
                  final canStart = isJoined && now.isAfter(contestDate.subtract(const Duration(minutes: 15)));

                  return FutureBuilder<String>(
                    future: _getTestTypeName(contest['test_type_id']),
                    builder: (context, testTypeSnapshot) {
                      if (!testTypeSnapshot.hasData) return const SizedBox.shrink();
                      return FutureBuilder<bool>(
                        future: _hasUserCompletedContest(contest.id, user.uid),
                        builder: (context, completedSnapshot) {
                          if (!completedSnapshot.hasData) return const SizedBox.shrink();
                          final hasCompleted = completedSnapshot.data!;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            child: ListTile(
                              title: Text("Contest: ${testTypeSnapshot.data}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Date: ${contest['date']}"),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8.0,
                                    children: [
                                      CustomButton(
                                        text: isJoined ? "Leave" : "Join",
                                        color: isJoined ? Colors.red : Colors.green,
                                        onPressed: () {
                                          if (isJoined) {
                                            _leaveContest(contest.id);
                                          } else {
                                            _joinContest(contest.id);
                                          }
                                        },
                                      ),
                                      CustomButton(
                                        text: isSubscribed ? "Unsubscribe" : "Subscribe",
                                        color: isSubscribed ? Colors.orange : Colors.blue,
                                        onPressed: () => _toggleNotifications(contest.id, !isSubscribed),
                                      ),
                                      if (isJoined && !hasCompleted)
                                        CustomButton(
                                          text: "Start",
                                          color: canStart ? Colors.green : Colors.grey,
                                          onPressed: canStart
                                              ? () async {
                                                  final categoryId = await _getFirstCategoryId(contest['test_type_id']);
                                                  final language = await _getFirstLanguage(contest['test_type_id'], categoryId);
                                                  context.go('/test', extra: {
                                                    'testTypeId': contest['test_type_id'],
                                                    'categoryId': categoryId,
                                                    'language': language,
                                                    'testName': testTypeSnapshot.data,
                                                    'categoryName': 'Contest Category',
                                                    'contestId': contest.id,
                                                  });
                                                }
                                              : null,
                                        ),
                                    ],
                                  ),
                                  if (hasCompleted)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "You have already completed this contest.",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
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
        currentIndex: 1, // Индекс текущего экрана (Contests)
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/training');
              break;
            case 1:
              break; // Уже на этом экране
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