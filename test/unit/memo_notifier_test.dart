import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memomemo/core/domain/memo.dart';
import 'package:memomemo/core/domain/mood.dart';
import 'package:memomemo/core/provider/memo_state.dart';
import 'package:memomemo/core/data/memo_repository.dart';

class _FakeMemoRepository implements MemoRepository {
  List<Memo> _storage = [];

  @override
  Future<void> saveToCloud(List<Memo> memos) async {}

  @override
  Future<void> saveAll(List<Memo> memos) async {
    _storage = [...memos];
  }

  @override
  List<Memo> fetchAll() => [..._storage];

  @override
  Future<void> deleteAll() async {
    _storage = [];
  }
}

class _IdGenerator {
  int _counter = 0;
  String call() => 'test-id-${_counter++}';
}

ProviderContainer _createContainer() {
  final repository = _FakeMemoRepository();
  final idGenerator = _IdGenerator();

  final container = ProviderContainer(
    overrides: [
      memoRepositoryProvider.overrideWithValue(repository),
      memoNotifierProvider.overrideWith(
        () => MemoNotifier(
          repositoryBuilder: () => repository,
          idGenerator: idGenerator.call,
        ),
      ),
    ],
  );

  addTearDown(container.dispose);
  return container;
}

void main() {

  test('初期状態は空であること', () {
    final container = _createContainer();

    // プロバイダーの状態を読み込む
    final state = container.read(memoNotifierProvider);

    // AsyncValue.data([]) であることを確認
    expect(state.value, isEmpty);
  });

  test('メモを追加できること', () async {
    final container = _createContainer();

    final notifier = container.read(memoNotifierProvider.notifier);

    // メモを追加
    await notifier.add(body: 'テストメモ', mood: Mood.happy);

    // 状態が更新されたか確認
    final state = container.read(memoNotifierProvider);

    // 1. エラーになっていないか
    expect(state.hasValue, true);
    // 2. リストの長さが1になっているか
    expect(state.value!.length, 1);
    // 3. 内容が正しいか
    expect(state.value!.first.body, 'テストメモ');
    expect(state.value!.first.mood, Mood.happy);
  });

  test('メモを削除できること', () async {
    final container = _createContainer();
    final notifier = container.read(memoNotifierProvider.notifier);

    // 1つ追加
    await notifier.add(body: '消すメモ', mood: Mood.tired);
    final addedMemo = container.read(memoNotifierProvider).value!.first;

    // 削除実行
    await notifier.delete(addedMemo.id);

    // 空になっているか確認
    final state = container.read(memoNotifierProvider);
    expect(state.value, isEmpty);
  });

  test('削除したメモを復元でき、メタデータも保持されること', () async {
    final container = _createContainer();
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
    final container = _createContainer();
    final notifier = container.read(memoNotifierProvider.notifier);

    await notifier.add(body: '重複しない', mood: Mood.calm);
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
