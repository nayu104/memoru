import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memomemo/core/domain/memo.dart';
import 'package:memomemo/core/domain/mood.dart';
import 'package:memomemo/core/provider/memo_state.dart';
import 'package:memomemo/features/widgets/memo_card.dart';

class FakeMemoCardNotifier extends MemoNotifier {
  Memo? deletedMemo;

  @override
  Future<List<Memo>> build() async => [];

  @override
  Future<Memo?> delete(String id) async {
    return deletedMemo = Memo(
      id: id,
      body: 'deleted',
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    );
  }
}

void main() {
  group('MemoCard', () {
    final now = DateTime(2025, 6, 15, 10, 30);
    final testMemo = Memo(
      id: 'test-1',
      body: '一行目のテキスト\n二行目のテキスト',
      mood: Mood.happy,
      createdAt: now,
      updatedAt: now,
    );

    Widget buildSubject({
      Memo? memo,
      MemoNotifier? notifier,
    }) {
      return ProviderScope(
        overrides: [
          memoNotifierProvider.overrideWith(
            () => notifier ?? FakeMemoCardNotifier(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [MemoCard(memo: memo ?? testMemo)],
            ),
          ),
        ),
      );
    }

    testWidgets(
      '一行目と二行目が表示される',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(
          find.text('一行目のテキスト'),
          findsOneWidget,
        );
        expect(
          find.text('二行目のテキスト'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '気分の絵文字が表示される',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('😄'), findsOneWidget);
      },
    );

    testWidgets(
      '日付がフォーマットされて表示される',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('2025/06/15'), findsOneWidget);
      },
    );

    testWidgets(
      '一行だけのメモの場合、二行目は表示されない',
      (tester) async {
        final singleLineMemo = Memo(
          id: 'single',
          body: '一行だけ',
          createdAt: now,
          updatedAt: now,
        );

        await tester.pumpWidget(
          buildSubject(memo: singleLineMemo),
        );
        await tester.pumpAndSettle();

        expect(find.text('一行だけ'), findsOneWidget);
      },
    );

    testWidgets(
      '各 Mood の絵文字が正しく表示される',
      (tester) async {
        for (final mood in Mood.values) {
          final memo = Memo(
            id: 'mood-${mood.name}',
            body: mood.label,
            mood: mood,
            createdAt: now,
            updatedAt: now,
          );

          await tester.pumpWidget(buildSubject(memo: memo));
          await tester.pumpAndSettle();

          expect(find.text(mood.emoji), findsOneWidget);
        }
      },
    );

    testWidgets(
      'カードが Card ウィジェットを使っている',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(Card), findsOneWidget);
      },
    );

    testWidgets(
      'Dismissible でスワイプ削除できる',
      (tester) async {
        final fakeNotifier = FakeMemoCardNotifier();
        await tester.pumpWidget(
          buildSubject(notifier: fakeNotifier),
        );
        await tester.pumpAndSettle();

        // 左にスワイプ
        await tester.drag(
          find.byType(Dismissible),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        expect(fakeNotifier.deletedMemo, isNotNull);
      },
    );

    testWidgets(
      '空のメモ本文でもクラッシュしない',
      (tester) async {
        final emptyMemo = Memo(
          id: 'empty',
          mood: Mood.tired,
          createdAt: now,
          updatedAt: now,
        );

        await tester.pumpWidget(
          buildSubject(memo: emptyMemo),
        );
        await tester.pumpAndSettle();

        expect(find.text('😩'), findsOneWidget);
      },
    );
  });
}
