import 'package:flutter/material.dart';
import '../../domain/models/mood.dart';

class NewMemoModal extends StatefulWidget {
  const NewMemoModal({super.key});

  @override
  State<NewMemoModal> createState() => _NewMemoModalState();
}

class _NewMemoModalState extends State<NewMemoModal> {
  Mood _selected = Mood.calm;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 560,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '新しいメモ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('今の気分を選んでください'),
              const SizedBox(height: 12),
              // Simple mood choice chips (replaces MoodSelector)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Mood.values.map((m) {
                  final selected = m == _selected;
                  return ChoiceChip(
                    label: Text('${m.emoji} ${m.label}'),
                    selected: selected,
                    onSelected: (_) => setState(() => _selected = m),
                    // avoid deprecated withOpacity by using withAlpha
                    selectedColor: m.color.withAlpha((0.9 * 255).round()),
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Text('メモ'),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Text(_selected.emoji),
                    label: const Text('作成'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
