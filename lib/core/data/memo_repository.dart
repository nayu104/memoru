import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/memo.dart';

// プロバイダー定義: アプリのどこからでもリポジトリにアクセスできるようにする
final memoRepositoryProvider = Provider<MemoRepository>((ref) {
  // main.dart で override してインスタンスを渡す想定
  throw UnimplementedError('Provider was not initialized');
});

class MemoRepository {
  MemoRepository(this._prefs);

  static const _kKey = 'memos_v1';
  final SharedPreferences _prefs;

  /// 保存 (新規・更新・削除すべてこのメソッド経由でリスト丸ごと保存)
  Future<void> saveAll(List<Memo> memos) async {
    final raw = jsonEncode(memos.map((e) => e.toJson()).toList());
    await _prefs.setString(_kKey, raw);
  }

  /// 全件取得
  List<Memo> fetchAll() {
    final raw = _prefs.getString(_kKey);
    if (raw == null) {
      return [];
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Memo.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 全件削除
  Future<void> deleteAll() async {
    await _prefs.remove(_kKey);
  }
}
