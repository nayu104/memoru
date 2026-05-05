import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memomemo/core/application/memo_state.dart';
import 'package:memomemo/core/data/local_memo_repository.dart';
import 'package:memomemo/core/domain/mood.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _createContainer() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      memoRepositoryProvider.overrideWithValue(LocalMemoRepository(prefs)),
    ],
  );
  await container.read(memoNotifierProvider.future);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('初期状態は空であること', () async {
    final container = await _createContainer();
    final state = container.read(memoNotifierProvider);
    expect(state.value, isEmpty);
  });

  test('メモを追加できること', () async {
    final container = await _createContainer();
    final notifier = container.read(memoNotifierProvider.notifier);

    await notifier.add(body: 'テストメモ', mood: Mood.happy);

    final state = container.read(memoNotifierProvider);
    expect(state.hasValue, true);
    expect(state.value!.length, 1);
    expect(state.value!.first.body, 'テストメモ');
    expect(state.value!.first.mood, Mood.happy);
  });

  test('メモを削除できること', () async {
    final container = await _createContainer();
    final notifier = container.read(memoNotifierProvider.notifier);

    await notifier.add(body: '消すメモ', mood: Mood.tired);
    final addedMemo = container.read(memoNotifierProvider).value!.first;

    await notifier.delete(addedMemo.id);

    final state = container.read(memoNotifierProvider);
    expect(state.value, isEmpty);
  });

  test('削除したメモを復元でき、メタデータも保持されること', () async {
    final container = await _createContainer();
    final notifier = container.read(memoNotifierProvider.notifier);

    await notifier.add(body: '復元メモ', mood: Mood.happy);
    final original = container.read(memoNotifierProvider).value!.first;

    final removed = await notifier.delete(original.id);
    expect(removed, isNotNull);

    await notifier.restore(removed!);

    final restored = container.read(memoNotifierProvider).value!;
    expect(restored, hasLength(1));
    expect(restored.first.id, original.id);
    expect(restored.first.createdAt, original.createdAt);
    expect(restored.first.updatedAt, original.updatedAt);
  });

  test('同じメモを重複復元しないこと', () async {
    final container = await _createContainer();
    final notifier = container.read(memoNotifierProvider.notifier);

    await notifier.add(body: '重複しない');
    final memo = container.read(memoNotifierProvider).value!.first;

    final removed = await notifier.delete(memo.id);
    expect(removed, isNotNull);

    await notifier.restore(removed!);
    await notifier.restore(removed);

    final restored = container.read(memoNotifierProvider).value!;
    expect(restored, hasLength(1));
    expect(restored.first.id, memo.id);
  });
}
