import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<String> _testTypes = [];
  List<String> _categories = [];
  List<String> _languages = [];
  String? _selectedTestType;
  String? _selectedTestTypeId;
  String? _selectedCategory;
  String? _selectedCategoryId;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      List<String> preferredTests = List<String>.from(userDoc['preferred_tests'] ?? []);

      // Загрузка доступных видов тестов
      QuerySnapshot testTypesSnapshot = await _firestore.collection('test_types').get();
      setState(() {
        _testTypes = testTypesSnapshot.docs
            .where((doc) => preferredTests.isEmpty || preferredTests.contains(doc['name']))
            .map((doc) => doc['name'] as String)
            .toList();
        if (_testTypes.isNotEmpty) {
          _selectedTestType = _testTypes.first;
          _selectedTestTypeId = testTypesSnapshot.docs
              .firstWhere((doc) => doc['name'] == _selectedTestType)
              .id;
          _loadCategories();
        }
      });
    }
  }

  Future<void> _loadCategories() async {
    if (_selectedTestTypeId == null) return;

    QuerySnapshot categoriesSnapshot = await _firestore
        .collection('test_types')
        .doc(_selectedTestTypeId)
        .collection('categories')
        .get();

    setState(() {
      _categories = categoriesSnapshot.docs.map((doc) => doc['name'] as String).toList();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
        _selectedCategoryId = categoriesSnapshot.docs
            .firstWhere((doc) => doc['name'] == _selectedCategory)
            .id;
        _loadLanguages();
      } else {
        _languages = [];
        _selectedLanguage = null;
      }
    });
  }

  Future<void> _loadLanguages() async {
    if (_selectedTestTypeId == null || _selectedCategoryId == null) return;

    DocumentSnapshot categoryDoc = await _firestore
        .collection('test_types')
        .doc(_selectedTestTypeId)
        .collection('categories')
        .doc(_selectedCategoryId)
        .get();

    setState(() {
      _languages = List<String>.from(categoryDoc['languages'] ?? []);
      _selectedLanguage = _languages.isNotEmpty ? _languages.first : null;
    });
  }

  void _startTest() {
    if (_selectedTestTypeId != null && _selectedCategoryId != null && _selectedLanguage != null) {
      context.go('/test', extra: {
        'testTypeId': _selectedTestTypeId,
        'categoryId': _selectedCategoryId,
        'language': _selectedLanguage,
        'testName': _selectedTestType,
        'categoryName': _selectedCategory,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a test, category, and language")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Testing Platform"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              context.go('/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_testTypes.isEmpty)
              Text("No tests available. Please select tests in Settings."),
            if (_testTypes.isNotEmpty)
              DropdownButton<String>(
                value: _selectedTestType,
                hint: Text("Select Test Type"),
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
                    _selectedTestTypeId = _firestore
                        .collection('test_types')
                        .where('name', isEqualTo: value)
                        .get()
                        .then((snapshot) => snapshot.docs.first.id);
                    _loadCategories();
                  });
                },
              ),
            SizedBox(height: 16),
            if (_categories.isNotEmpty)
              DropdownButton<String>(
                value: _selectedCategory,
                hint: Text("Select Category"),
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
                    _selectedCategoryId = _firestore
                        .collection('test_types')
                        .doc(_selectedTestTypeId)
                        .collection('categories')
                        .where('name', isEqualTo: value)
                        .get()
                        .then((snapshot) => snapshot.docs.first.id);
                    _loadLanguages();
                  });
                },
              ),
            SizedBox(height: 16),
            if (_languages.isNotEmpty)
              DropdownButton<String>(
                value: _selectedLanguage,
                hint: Text("Select Language"),
                isExpanded: true,
                items: _languages.map((language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startTest,
              child: Text("Start Test"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Training"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Contests"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Results"),
        ],
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
  }
}