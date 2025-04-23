import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      String theme = userDoc['theme'] ?? 'light';
      _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).update({
        'theme': themeMode == ThemeMode.dark ? 'dark' : 'light',
      });
    }
    notifyListeners();
  }
}