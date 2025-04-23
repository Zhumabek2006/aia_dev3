import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_button.dart';
import '../widgets/list_item.dart';

class AdminContestsScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _deleteContest(String contestId) async {
    await _firestore.collection('contests').doc(contestId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('contests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final contests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: contests.length,
            itemBuilder: (context, index) {
              final contest = contests[index];
              return ListItem(
                title: "Contest on ${contest['date']}",
                onEdit: () {
                  context.go('/admin/edit-contest', extra: {
                    'id': contest.id,
                    'testTypeId': contest['test_type_id'],
                    'date': contest['date'],
                  });
                },
                onDelete: () => _deleteContest(contest.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/admin/add-contest'),
        child: const Icon(Icons.add),
      ),
    );
  }
}