import 'package:flutter/material.dart';
import '../../domain/models/memo.dart';
import '../../domain/models/mood.dart';

class MemoDetailScreen extends StatelessWidget {
  final Memo memo;
  const MemoDetailScreen({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(memo.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${memo.mood.emoji} ${memo.mood.label}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(memo.body, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
