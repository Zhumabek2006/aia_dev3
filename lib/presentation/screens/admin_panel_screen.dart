import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => AdminPanelScreenState();
}

class AdminPanelScreenState extends State<AdminPanelScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> _isAdmin() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc['role'] == 'admin';
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdmin(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (!snapshot.data!) {
          return const Center(child: Text("Access Denied: Admins Only"));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Admin Panel"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await _auth.signOut();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ElevatedButton(
                  onPressed: null,
                  child: Text("Test Types"),
                ),
                const SizedBox(height: 16),
                const ElevatedButton(
                  onPressed: null,
                  child: Text("Contests"),
                ),
                const SizedBox(height: 16),
                const ElevatedButton(
                  onPressed: null,
                  child: Text("Study Materials"),
                ),
              ],
            ),
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
            currentIndex: 0,
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
                  context.go('/results');
                  break;
              }
            },
          ),
        );
      },
    );
  }
}