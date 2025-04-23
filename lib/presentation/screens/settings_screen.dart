import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../domain/providers/theme_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  List<String> _availableTests = [];
  List<String> _selectedTests = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAvailableTests();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _emailController.text = userDoc['email'] ?? '';
        _selectedTests = List<String>.from(userDoc['preferred_tests'] ?? []);
      });
    }
  }

  Future<void> _loadAvailableTests() async {
    QuerySnapshot testTypesSnapshot = await _firestore.collection('test_types').get();
    setState(() {
      _availableTests = testTypesSnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> _updateEmail() async {
    final user = _auth.currentUser;
    if (user != null && _emailController.text.trim() != user.email) {
      try {
        await user.updateEmail(_emailController.text.trim());
        await _firestore.collection('users').doc(user.uid).update({
          'email': _emailController.text.trim(),
        });
        setState(() {
          _errorMessage = "Email updated successfully";
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'preferred_tests': _selectedTests,
      });
      setState(() {
        _errorMessage = "Settings saved successfully";
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    context.go('/');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Change Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              CustomTextField(
                controller: _emailController,
                labelText: "Email",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),
              CustomButton(
                text: "Update Email",
                onPressed: _updateEmail,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text("Select Theme", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: themeProvider.themeMode == ThemeMode.dark ? 'dark' : 'light',
                hint: const Text("Select Theme"),
                isExpanded: true,
                items: ['light', 'dark'].map((theme) {
                  return DropdownMenuItem<String>(
                    value: theme,
                    child: Text(theme),
                  );
                }).toList(),
                onChanged: (value) {
                  themeProvider.setTheme(value == 'dark' ? ThemeMode.dark : ThemeMode.light);
                },
              ),
              const SizedBox(height: 16),
              const Text("Select Test Types", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ..._availableTests.map((test) {
                return CheckboxListTile(
                  title: Text(test),
                  value: _selectedTests.contains(test),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedTests.add(test);
                      } else {
                        _selectedTests.remove(test);
                      }
                    });
                  },
                );
              }).toList(),
              CustomButton(
                text: "Save Settings",
                onPressed: _saveSettings,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: _errorMessage!.contains("successfully") ? Colors.green : Colors.red),
                ),
              const SizedBox(height: 16),
              CustomButton(
                text: "Logout",
                onPressed: _logout,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}