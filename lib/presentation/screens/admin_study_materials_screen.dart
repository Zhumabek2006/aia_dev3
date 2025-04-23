import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_button.dart';
import '../widgets/list_item.dart';

class AdminStudyMaterialsScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _deleteStudyMaterial(String testTypeId, String materialId) async {
    await _firestore
        .collection('test_types')
        .doc(testTypeId)
        .collection('study_materials')
        .doc(materialId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('test_types').snapshots(),
        builder: (context, testSnapshot) {
          if (!testSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final testTypes = testSnapshot.data!.docs;
          return ListView.builder(
            itemCount: testTypes.length,
            itemBuilder: (context, testIndex) {
              final testType = testTypes[testIndex];
              return ExpansionTile(
                title: Text(testType['name']),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('test_types')
                        .doc(testType.id)
                        .collection('study_materials')
                        .snapshots(),
                    builder: (context, matSnapshot) {
                      if (!matSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final materials = matSnapshot.data!.docs;
                      return Column(
                        children: materials.map((material) {
                          return ListItem(
                            title: material['title'],
                            onEdit: () {
                              context.go('/admin/edit-study-material', extra: {
                                'testTypeId': testType.id,
                                'materialId': material.id,
                                'title': material['title'],
                                'content': material['content'],
                              });
                            },
                            onDelete: () => _deleteStudyMaterial(testType.id, material.id),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  CustomButton(
                    text: "Add Study Material to ${testType['name']}",
                    onPressed: () {
                      context.go('/admin/add-study-material', extra: {'testTypeId': testType.id});
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