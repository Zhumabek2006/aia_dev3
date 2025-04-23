import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_button.dart';
import '../widgets/list_item.dart';

class AdminTestTypesScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _deleteTestType(String testTypeId) async {
    await _firestore.collection('test_types').doc(testTypeId).delete();
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
              return ListItem(
                title: testType['name'],
                onEdit: () {
                  context.go('/admin/edit-test-type', extra: {
                    'id': testType.id,
                    'name': testType['name'],
                  });
                },
                onDelete: () => _deleteTestType(testType.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/admin/add-test-type'),
        child: const Icon(Icons.add),
      ),
    );
  }
}