import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memomemo/core/data/memo_repository.dart';
import 'package:memomemo/core/domain/mood.dart';
import 'package:memomemo/core/provider/memo_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late MemoNotifier notifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        memoRepositoryProvider.overrideWithValue(
          MemoRepository(prefs),
        ),
      ],
    );
    // build() を完了させる
    await container.read(memoNotifierProvider.future);
    notifier = container.read(memoNotifierProvider.notifier);
  });

  tearDown(() => container.dispose());

  group('基本操作', () {
    test('初期状態は空', () async {
      final memos = await container.read(
        memoNotifierProvider.future,
      );
      expect(memos, isEmpty);
    });

    test('メモを追加できる', () async {
      await notifier.add(body: 'テスト', mood: Mood.happy);

      final state = container.read(memoNotifierProvider);
      expect(state.value!.length, 1);
      expect(state.value!.first.body, 'テスト');
      expect(state.value!.first.mood, Mood.happy);
    });

    test('メモを更新できる', () async {
      await notifier.add(body: '古い');
      final original = container.read(
        memoNotifierProvider,
      ).value!.first;

      final updated = original.copyWith(
        body: '新しい',
        mood: Mood.fired,
      );
      await notifier.updateMemo(updated);

      final result = container.read(
        memoNotifierProvider,
      ).value!.first;
      expect(result.body, '新しい');
      expect(result.mood, Mood.fired);
      expect(result.id, original.id);
    });

    test('メモを削除できる', () async {
      await notifier.add(body: '消す', mood: Mood.tired);
      final memo = container.read(
        memoNotifierProvider,
      ).value!.first;

      final deleted = await notifier.delete(memo.id);
      expect(deleted, isNotNull);
      expect(deleted!.body, '消す');

      final state = container.read(memoNotifierProvider);
      expect(state.value, isEmpty);
    });

    test('存在しないIDを削除するとnullが返る', () async {
      final result = await notifier.delete('non-existent');
      expect(result, isNull);
    });
  });

  group('deleteAll', () {
    test('全メモを削除できる', () async {
      await notifier.add(body: 'メモ1', mood: Mood.happy);
      await notifier.add(body: 'メモ2', mood: Mood.tired);

      expect(
        container.read(memoNotifierProvider).value!.length,
        2,
      );

      await notifier.deleteAll();

      final state = container.read(memoNotifierProvider);
      expect(state.value, isEmpty);
    });

    test('空の状態で deleteAll しても問題ない', () async {
      await notifier.deleteAll();
      final state = container.read(memoNotifierProvider);
      expect(state.value, isEmpty);
    });
  });

  group('backupToCloud', () {
    test(
      'メモが空の場合はエラーを返す',
      () async {
        final result = await notifier.backupToCloud();
        expect(result.success, false);
        expect(
          result.errorMessage,
          'バックアップするメモがありません',
        );
      },
    );
  });

  group('デフォルトの mood', () {
    test(
      'mood を省略すると Mood.calm になる',
      () async {
        await notifier.add(body: 'デフォルト気分');

        final state = container.read(memoNotifierProvider);
        expect(state.value!.first.mood, Mood.calm);
      },
    );
  });

  group('複数メモの操作', () {
    test('追加は先頭に入る', () async {
      await notifier.add(body: '1番目');
      await notifier.add(body: '2番目', mood: Mood.happy);

      final memos = container.read(
        memoNotifierProvider,
      ).value!;
      expect(memos[0].body, '2番目');
      expect(memos[1].body, '1番目');
    });

    test(
      '特定のメモだけ更新される',
      () async {
        await notifier.add(body: 'A');
        await notifier.add(body: 'B', mood: Mood.happy);

        final memos = container.read(
          memoNotifierProvider,
        ).value!;
        // B が先頭
        final bMemo = memos[0];
        final updated = bMemo.copyWith(body: 'B-updated');
        await notifier.updateMemo(updated);

        final result = container.read(
          memoNotifierProvider,
        ).value!;
        expect(result[0].body, 'B-updated');
        expect(result[1].body, 'A');
      },
    );
  });
}
