import 'package:flutter/material.dart';
import '../../domain/models/memo.dart';
import '../../domain/models/mood.dart';
import '../widgets/memo_card.dart';

class MemoListScreen extends StatelessWidget {
  const MemoListScreen({super.key});

  List<Memo> _sample() {
    return [
      Memo(id: '1', title: 'Flutter勉強', body: 'State管理を学んだ', mood: Mood.happy),
      Memo(id: '2', title: 'ゼミのメモ', body: '今日の発表', mood: Mood.calm),
      Memo(id: '3', title: '体調メモ', body: 'ちょっとしんどい', mood: Mood.tired),
      Memo(id: '4', title: 'やること', body: 'サイドプロジェクト', mood: Mood.fired),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _sample();
    return Scaffold(
      appBar: AppBar(
        title: const Text('気分×色メモ'),
        actions: const [Padding(padding: EdgeInsets.only(right: 8.0))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: '検索',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                itemBuilder: (context, index) => MemoCard(memo: items[index]),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: items.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
