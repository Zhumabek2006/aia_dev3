import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _firestore = FirebaseFirestore.instance;
  String? _selectedTestType;
  String? _selectedCategory;
  String? _selectedLanguage;
  List<String> _testTypes = [];
  List<String> _categories = [];
  List<String> _languages = [];

  @override
  void initState() {
    super.initState();
    _loadTestTypes();
  }

  Future<void> _loadTestTypes() async {
    QuerySnapshot testTypesSnapshot = await _firestore.collection('test_types').get();
    setState(() {
      _testTypes = testTypesSnapshot.docs.map((doc) => doc['name'] as String).toList();
      if (_testTypes.isNotEmpty) {
        _selectedTestType = _testTypes.first;
        _loadCategories(_selectedTestType!);
      }
    });
  }

  Future<void> _loadCategories(String testType) async {
    QuerySnapshot testTypesSnapshot = await _firestore.collection('test_types').where('name', isEqualTo: testType).get();
    if (testTypesSnapshot.docs.isEmpty) return;

    String testTypeId = testTypesSnapshot.docs.first.id;
    QuerySnapshot categoriesSnapshot = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .get();

    setState(() {
      _categories = categoriesSnapshot.docs.map((doc) => doc['name'] as String).toList();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
        _loadLanguages(testTypeId, _selectedCategory!);
      }
    });
  }

  Future<void> _loadLanguages(String testTypeId, String category) async {
    QuerySnapshot categoriesSnapshot = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .where('name', isEqualTo: category)
        .get();

    if (categoriesSnapshot.docs.isEmpty) return;

    final categoryDoc = categoriesSnapshot.docs.first;
    setState(() {
      _languages = List<String>.from(categoryDoc['languages'] ?? []);
      if (_languages.isNotEmpty) {
        _selectedLanguage = _languages.first;
      }
    });
  }

  Future<String> _getTestTypeId(String testType) async {
    QuerySnapshot testTypesSnapshot = await _firestore
        .collection('test_types')
        .where('name', isEqualTo: testType)
        .get();
    return testTypesSnapshot.docs.first.id;
  }

  Future<String> _getCategoryId(String testTypeId, String category) async {
    QuerySnapshot categoriesSnapshot = await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .where('name', isEqualTo: category)
        .get();
    return categoriesSnapshot.docs.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Testing Platform"),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              context.go('/admin');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Test Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  _categories = [];
                  _selectedCategory = null;
                  _languages = [];
                  _selectedLanguage = null;
                });
                _loadCategories(value!);
              },
            ),
            const SizedBox(height: 16),
            const Text("Select Category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              onChanged: (value) async {
                setState(() {
                  _selectedCategory = value;
                  _languages = [];
                  _selectedLanguage = null;
                });
                String testTypeId = await _getTestTypeId(_selectedTestType!);
                _loadLanguages(testTypeId, value!);
              },
            ),
            const SizedBox(height: 16),
            const Text("Select Language", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedLanguage,
              hint: const Text("Select Language"),
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
            const SizedBox(height: 16),
            CustomButton(
              text: "Start Test",
              onPressed: () async {
                if (_selectedTestType != null && _selectedCategory != null && _selectedLanguage != null) {
                  String testTypeId = await _getTestTypeId(_selectedTestType!);
                  String categoryId = await _getCategoryId(testTypeId, _selectedCategory!);
                  if (mounted) {
                    context.go('/test', extra: {
                      'testTypeId': testTypeId,
                      'categoryId': categoryId,
                      'language': _selectedLanguage!,
                      'testName': _selectedTestType!,
                      'categoryName': _selectedCategory!,
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a test type, category, and language")),
                  );
                }
              },
              color: Colors.green,
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
  }
}