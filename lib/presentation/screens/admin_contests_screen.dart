import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminContestsScreen extends StatelessWidget {
  const AdminContestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contests"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/admin/add-contest');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('contests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final contests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: contests.length,
            itemBuilder: (context, index) {
              final contest = contests[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('test_types')
                    .doc(contest['test_type_id'])
                    .get(),
                builder: (context, testTypeSnapshot) {
                  if (!testTypeSnapshot.hasData) return const SizedBox.shrink();
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: ListTile(
                      title: Text("Contest: ${testTypeSnapshot.data!['name']}"),
                      subtitle: Text("Date: ${contest['date']}"),
                      onTap: () {
                        context.go(
                          '/admin/edit-contest',
                          extra: {'contestId': contest.id},
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}