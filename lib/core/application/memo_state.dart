import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/local_memo_repository.dart';
import '../domain/memo.dart';
import '../domain/memo_repository.dart';
import '../domain/mood.dart';

// プロバイダー定義
// UI側からは ref.watch(memoNotifierProvider) でこのNotifierの状態（リスト）を監視します。
final memoNotifierProvider = AsyncNotifierProvider<MemoNotifier, List<Memo>>(
  MemoNotifier.new,
);

class MemoNotifier extends AsyncNotifier<List<Memo>> {
  static const _uuid = Uuid();

  /// 初期データをロードします。
  @override
  Future<List<Memo>> build() async {
    return _fetchAll();
  }

  MemoRepository get _repository => ref.read(memoRepositoryProvider);

  /// リポジトリからデータを全件取得
  List<Memo> _fetchAll() {
    return _repository.fetchAll();
  }

  /// 内部ヘルパー: データを保存し、同時に画面の状態（state）も更新する
  /// 保存失敗時は AsyncError に遷移し、UI が「何が起きたか」判断できるようにする
  Future<void> _saveAndRefresh(List<Memo> newMemos) async {
    state = await AsyncValue.guard(() async {
      await _repository.saveAll(newMemos);
      return newMemos;
    });
  }

  /// 新規作成
  Future<void> add({required String body, Mood mood = Mood.calm}) async {
    final currentList = state.value ?? [];
    final newMemo = Memo.create(
      id: _uuid.v4(),
      body: body,
      mood: mood,
    );
    await _saveAndRefresh([newMemo, ...currentList]);
  }

  /// 更新
  Future<void> updateMemo(Memo updatedMemo) async {
    final currentList = state.value ?? [];
    final newList = [
      for (final memo in currentList)
        if (memo.id == updatedMemo.id) updatedMemo else memo,
    ];
    await _saveAndRefresh(newList);
  }

  /// 削除。成功した場合は削除したMemoを返す（Undo用）
  Future<Memo?> delete(String id) async {
    final currentList = state.value ?? [];
    final targetIndex = currentList.indexWhere((m) => m.id == id);
    if (targetIndex == -1) {
      return null;
    }

    final target = currentList[targetIndex];
    final newList = currentList.where((m) => m.id != id).toList();
    await _saveAndRefresh(newList);
    return target;
  }

  /// 削除したメモを復元する
  Future<void> restore(Memo memo) async {
    final currentList = state.value ?? [];
    final newList = [
      memo,
      ...currentList.where((existing) => existing.id != memo.id),
    ];
    await _saveAndRefresh(newList);
  }

  /// 全件削除
  Future<void> deleteAll() async {
    await _repository.deleteAll();
    state = const AsyncData(<Memo>[]);
  }
}
