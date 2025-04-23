import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminStudyMaterialsScreen extends StatelessWidget {
  const AdminStudyMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final testTypeId = data['testTypeId'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Materials"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/admin/add-study-material', extra: {'testTypeId': testTypeId});
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('test_types')
            .doc(testTypeId)
            .collection('study_materials')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final materials = snapshot.data!.docs;
          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final material = materials[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: ListTile(
                  title: Text(material['title']),
                  subtitle: Text("Created: ${material['created_at']}"),
                  onTap: () {
                    context.go(
                      '/admin/edit-study-material',
                      extra: {
                        'testTypeId': testTypeId,
                        'materialId': material.id,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}