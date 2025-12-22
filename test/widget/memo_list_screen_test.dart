import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memomemo/core/domain/memo.dart';
import 'package:memomemo/core/domain/mood.dart';
import 'package:memomemo/core/provider/memo_state.dart';
import 'package:memomemo/features/screens/memo_list_screen.dart';
import 'package:memomemo/features/widgets/memo_card.dart';

class FakeMemoNotifier extends MemoNotifier {
  final List<Memo> initialMemos;
  FakeMemoNotifier(this.initialMemos);

  @override
  Future<List<Memo>> build() async {
    return initialMemos;
  }
}

void main() {
  testWidgets('メモ一覧が表示されること', (WidgetTester tester) async {
    final memos = [
      Memo(
        id: '1',
        body: 'メモ1',
        mood: Mood.happy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Memo(
        id: '2',
        body: 'メモ2',
        mood: Mood.tired,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoNotifierProvider.overrideWith(() => FakeMemoNotifier(memos)),
        ],
        child: const MaterialApp(
          home: MemoListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('メモ1'), findsOneWidget);
    expect(find.text('メモ2'), findsOneWidget);
    expect(find.byType(MemoCard), findsNWidgets(2));
  });

  testWidgets('検索機能が動作すること', (WidgetTester tester) async {
    final memos = [
      Memo(
        id: '1',
        body: 'りんご',
        mood: Mood.happy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Memo(
        id: '2',
        body: 'ばなな',
        mood: Mood.tired,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoNotifierProvider.overrideWith(() => FakeMemoNotifier(memos)),
        ],
        child: const MaterialApp(
          home: MemoListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 検索フィールドに入力
    await tester.enterText(find.byType(TextField), 'りんご');
    await tester.pumpAndSettle();

    // りんごは表示され、ばななは表示されない
    expect(find.descendant(of: find.byType(MemoCard), matching: find.text('りんご')), findsOneWidget);
    expect(find.text('ばなな'), findsNothing);
  });
}
