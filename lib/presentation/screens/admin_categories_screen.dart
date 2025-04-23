import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_button.dart';
import '../widgets/list_item.dart';

class AdminCategoriesScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _deleteCategory(String testTypeId, String categoryId) async {
    await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('test_types').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final testTypes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: testTypes.length,
            itemBuilder: (context, index) {
              final testType = testTypes[index];
              return ExpansionTile(
                title: Text(testType['name']),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('test_types')
                        .doc(testType.id)
                        .collection('categories')
                        .snapshots(),
                    builder: (context, catSnapshot) {
                      if (!catSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final categories = catSnapshot.data!.docs;
                      return Column(
                        children: categories.map((category) {
                          return ListItem(
                            title: category['name'],
                            onEdit: () {
                              context.go('/admin/edit-category', extra: {
                                'testTypeId': testType.id,
                                'categoryId': category.id,
                                'name': category['name'],
                                'duration': category['duration'],
                                'languages': category['languages'],
                                'pointsPerQuestion': category['points_per_question'],
                              });
                            },
                            onDelete: () => _deleteCategory(testType.id, category.id),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  CustomButton(
                    text: "Add Category to ${testType['name']}",
                    onPressed: () {
                      context.go('/admin/add-category', extra: {'testTypeId': testType.id});
                    },
                    color: Colors.green,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}