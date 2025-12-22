import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memomemo/core/domain/mood.dart';
import 'package:memomemo/core/domain/memo.dart';
import '../../core/provider/memo_state.dart';

class NewMemoModal extends ConsumerStatefulWidget {
  final Memo? initial;
  const NewMemoModal({super.key, this.initial});

  @override
  ConsumerState<NewMemoModal> createState() => _NewMemoModalState();
}

class _NewMemoModalState extends ConsumerState<NewMemoModal> {
  Mood _selected = Mood.calm;
  final TextEditingController _controller = TextEditingController();

  // メモ編集画面が開かれた瞬間に、既存のメモデータを画面にセットする
  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _selected = initial.mood;
      _controller.text = initial.body;
    }
  }

  Future<void> _saveAndClose() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final notifier = ref.read(memoNotifierProvider.notifier);

    if (widget.initial == null) {
      await notifier.add(body: text, mood: _selected);
    } else {
      // 変更がない場合は更新しない
      if (widget.initial!.body == text && widget.initial!.mood == _selected) {
        if (mounted) Navigator.of(context).pop();
        return;
      }

      final updated = widget.initial!.copyWith(
        body: text,
        mood: _selected,
        updatedAt: DateTime.now(),
      );
      await notifier.updateMemo(updated);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _saveAndClose();
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 100,
          leading: TextButton(
            onPressed: _saveAndClose,
            child: const Row(
              children: [Icon(Icons.arrow_back_ios, size: 18), Text('戻る')],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              child: const Text(
                '完了',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text('今の気分', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),

              // Mood Selector
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Mood.values.map((mood) {
                  final isSelected = mood == _selected;
                  final selectedColor = mood.color.withAlpha(200);

                  return ChoiceChip(
                    label: Text('${mood.emoji} ${mood.label}'),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selected = mood),
                    selectedColor: selectedColor,
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),
              const Text('メモ', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),

              // Body Input
              Expanded(
                child: TextField(
                  controller: _controller,
                  expands: true,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top, // 上寄せ
                  decoration: const InputDecoration(
                    hintText: '今、何を考えてる？',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
