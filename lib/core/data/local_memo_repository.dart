import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/memo.dart';
import '../domain/memo_repository.dart';

/// SharedPreferences を使ったローカル永続化の具体実装
class LocalMemoRepository implements MemoRepository {
  LocalMemoRepository(this._prefs);

  static const _kKey = 'memos_v1';
  final SharedPreferences _prefs;

  @override
  Future<void> saveAll(List<Memo> memos) async {
    final raw = jsonEncode(memos.map((e) => e.toJson()).toList());
    await _prefs.setString(_kKey, raw);
  }

  @override
  List<Memo> fetchAll() {
    final raw = _prefs.getString(_kKey);
    if (raw == null) {
      return [];
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Memo.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> deleteAll() async {
    await _prefs.remove(_kKey);
  }
}

/// プロバイダー定義: main.dart で override して LocalMemoRepository を渡す
final memoRepositoryProvider = Provider<MemoRepository>((ref) {
  throw UnimplementedError('memoRepositoryProvider was not initialized');
});
