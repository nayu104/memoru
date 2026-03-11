import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/memo.dart';

/// クラウド保存の結果を表すクラス
class CloudSaveResult {
  const CloudSaveResult._({
    required this.success,
    this.errorMessage,
    this.requiresAuth = false,
  });

  factory CloudSaveResult.success() => const CloudSaveResult._(success: true);

  factory CloudSaveResult.authRequired() => const CloudSaveResult._(
    success: false,
    errorMessage: 'ログインが必要です',
    requiresAuth: true,
  );

  factory CloudSaveResult.error(String message) => CloudSaveResult._(
    success: false,
    errorMessage: message,
  );

  final bool success;
  final String? errorMessage;
  final bool requiresAuth;
}

// プロバイダー定義: アプリのどこからでもリポジトリにアクセスできるようにする
final memoRepositoryProvider = Provider<MemoRepository>((ref) {
  // main.dart で override してインスタンスを渡す想定
  throw UnimplementedError('Provider was not initialized');
});

class MemoRepository {
  MemoRepository(this._prefs);

  static const _kKey = 'memos_v1';
  final SharedPreferences _prefs;

  /// クラウドにバックアップ（OAuthログイン済みユーザーのみ）
  Future<CloudSaveResult> saveToCloud(List<Memo> memos) async {
    final user = FirebaseAuth.instance.currentUser;

    // 未ログインまたは匿名ユーザーの場合はエラー
    if (user == null || user.isAnonymous) {
      return CloudSaveResult.authRequired();
    }

    try {
      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;

      // 一括書き込みの準備 (500件まで1回の通信で送れる)
      final batch = firestore.batch();

      final collectionRef = firestore
          .collection('users')
          .doc(uid)
          .collection('memos');

      for (final memo in memos) {
        final docRef = collectionRef.doc(memo.id);
        batch.set(docRef, memo.toJson());
      }

      await batch.commit();
      return CloudSaveResult.success();
    } on Exception catch (e) {
      return CloudSaveResult.error('バックアップに失敗しました: $e');
    }
  }

  /// クラウドからメモを復元（OAuthログイン済みユーザーのみ）
  Future<List<Memo>?> restoreFromCloud() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      return null;
    }

    try {
      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;

      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('memos')
          .get();

      return snapshot.docs.map((doc) => Memo.fromJson(doc.data())).toList();
    } on Exception {
      return null;
    }
  }

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
