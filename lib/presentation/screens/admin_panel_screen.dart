import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'admin_test_types_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_questions_screen.dart';
import 'admin_contests_screen.dart';
import 'admin_study_materials_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Test Types"),
            Tab(text: "Categories"),
            Tab(text: "Questions"),
            Tab(text: "Contests"),
            Tab(text: "Study Materials"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.go('/');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AdminTestTypesScreen(),
          AdminCategoriesScreen(),
          AdminQuestionsScreen(),
          AdminContestsScreen(),
          AdminStudyMaterialsScreen(),
        ],
      ),
    );
  }
}