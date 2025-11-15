import 'package:flutter/material.dart';
import '../../domain/models/memo.dart';
import '../../domain/models/mood.dart';
import '../screens/memo_detail_screen.dart';

class MemoCard extends StatelessWidget {
  final Memo memo;
  const MemoCard({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MemoDetailScreen(memo: memo)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 56,
              decoration: BoxDecoration(
                color: memo.mood.color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(memo.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(memo.body, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(memo.mood.emoji, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
