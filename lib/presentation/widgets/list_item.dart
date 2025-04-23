import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ListItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}