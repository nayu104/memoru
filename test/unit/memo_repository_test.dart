import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memomemo/core/data/memo_repository.dart';
import 'package:memomemo/core/domain/memo.dart';
import 'package:memomemo/core/domain/mood.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CloudSaveResult', () {
    test('success() は success=true を返す', () {
      final result = CloudSaveResult.success();
      expect(result.success, true);
      expect(result.errorMessage, isNull);
      expect(result.requiresAuth, false);
    });

    test('authRequired() は requiresAuth=true を返す', () {
      final result = CloudSaveResult.authRequired();
      expect(result.success, false);
      expect(result.requiresAuth, true);
      expect(result.errorMessage, 'ログインが必要です');
    });

    test('error() はエラーメッセージを持つ', () {
      final result = CloudSaveResult.error('テストエラー');
      expect(result.success, false);
      expect(result.errorMessage, 'テストエラー');
      expect(result.requiresAuth, false);
    });
  });

  group('MemoRepository (ローカル保存)', () {
    late MemoRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = MemoRepository(prefs);
    });

    test('初期状態では空リストを返す', () {
      final memos = repository.fetchAll();
      expect(memos, isEmpty);
    });

    test('saveAll で保存したメモを fetchAll で取得できる', () async {
      final now = DateTime(2025);
      final memos = [
        Memo(
          id: '1',
          body: 'テスト1',
          mood: Mood.happy,
          createdAt: now,
          updatedAt: now,
        ),
        Memo(
          id: '2',
          body: 'テスト2',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await repository.saveAll(memos);
      final result = repository.fetchAll();

      expect(result.length, 2);
      expect(result[0].id, '1');
      expect(result[0].body, 'テスト1');
      expect(result[0].mood, Mood.happy);
      expect(result[1].id, '2');
      expect(result[1].body, 'テスト2');
    });

    test('deleteAll で全件削除できる', () async {
      final now = DateTime(2025);
      final memos = [
        Memo(
          id: '1',
          body: 'テスト',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await repository.saveAll(memos);
      expect(repository.fetchAll(), isNotEmpty);

      await repository.deleteAll();
      expect(repository.fetchAll(), isEmpty);
    });

    test('空リストを保存できる', () async {
      await repository.saveAll([]);
      final result = repository.fetchAll();
      expect(result, isEmpty);
    });

    test(
      '既存データがある状態で saveAll すると上書きされる',
      () async {
        final now = DateTime(2025);
        await repository.saveAll([
          Memo(
            id: '1',
            body: '古い',
            createdAt: now,
            updatedAt: now,
          ),
        ]);

        await repository.saveAll([
          Memo(
            id: '2',
            body: '新しい',
            mood: Mood.happy,
            createdAt: now,
            updatedAt: now,
          ),
        ]);

        final result = repository.fetchAll();
        expect(result.length, 1);
        expect(result.first.id, '2');
        expect(result.first.body, '新しい');
      },
    );

    test(
      'SharedPreferences に不正な JSON がある場合',
      () async {
        // 直接 SharedPreferences に不正データを入れる
        SharedPreferences.setMockInitialValues(
          {'memos_v1': 'invalid-json'},
        );
        final prefs = await SharedPreferences.getInstance();
        final repo = MemoRepository(prefs);

        expect(repo.fetchAll, throwsA(isA<FormatException>()));
      },
    );
  });

  group('MemoRepository (JSON変換)', () {
    test('メモが正しくJSON変換される', () {
      final now = DateTime(2025, 6, 15, 10, 30);
      final memo = Memo(
        id: 'test-id',
        body: 'JSONテスト',
        mood: Mood.fired,
        createdAt: now,
        updatedAt: now,
      );

      final json = memo.toJson();
      final restored = Memo.fromJson(json);

      expect(restored.id, 'test-id');
      expect(restored.body, 'JSONテスト');
      expect(restored.mood, Mood.fired);
      expect(restored.createdAt, now);
      expect(restored.updatedAt, now);
    });

    test('Memo.create でIDと時刻が設定される', () {
      final memo = Memo.create(
        id: 'new-id',
        body: '作成テスト',
        mood: Mood.happy,
      );

      expect(memo.id, 'new-id');
      expect(memo.body, '作成テスト');
      expect(memo.mood, Mood.happy);
      expect(memo.createdAt, isNotNull);
      expect(memo.updatedAt, isNotNull);
      expect(memo.createdAt, memo.updatedAt);
    });

    test(
      'saveAll → fetchAll のラウンドトリップで '
      'データが正確に保持される',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = MemoRepository(prefs);

        final now = DateTime(2025, 3, 15, 12);
        final memos = [
          Memo(
            id: 'a',
            body: '改行\nテスト',
            mood: Mood.happy,
            createdAt: now,
            updatedAt: now,
          ),
          Memo(
            id: 'b',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        await repo.saveAll(memos);

        // SharedPreferences の中身を直接確認
        final raw = prefs.getString('memos_v1');
        expect(raw, isNotNull);
        final decoded = jsonDecode(raw!) as List;
        expect(decoded.length, 2);

        // fetchAll で復元確認
        final restored = repo.fetchAll();
        expect(restored[0].body, '改行\nテスト');
        expect(restored[1].body, '');
      },
    );
  });
}
