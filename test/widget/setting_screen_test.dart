import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memomemo/core/data/memo_repository.dart';
import 'package:memomemo/core/domain/memo.dart';
import 'package:memomemo/core/provider/memo_state.dart';
import 'package:memomemo/features/screens/setting_screen.dart';

import '../mock_firebase.dart';

// バックアップ / 復元テスト用の Notifier
class FakeSettingNotifier extends MemoNotifier {
  bool backupCalled = false;
  bool deleteAllCalled = false;

  @override
  Future<List<Memo>> build() async => [];

  @override
  Future<CloudSaveResult> backupToCloud() async {
    backupCalled = true;
    return CloudSaveResult.success();
  }

  @override
  Future<void> deleteAll() async {
    deleteAllCalled = true;
    state = const AsyncData([]);
  }
}

class FailBackupNotifier extends MemoNotifier {
  @override
  Future<List<Memo>> build() async => [];

  @override
  Future<CloudSaveResult> backupToCloud() {
    throw Exception('バックアップ失敗');
  }
}

void main() {
  setUpAll(setupFirebaseMocks);

  group('SettingScreen', () {
    late FakeSettingNotifier fakeNotifier;

    setUp(() {
      fakeNotifier = FakeSettingNotifier();
    });

    Widget buildSubject({MemoNotifier? notifier}) {
      final router = GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(
              body: Text('Home'),
            ),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (_, _) => const SettingScreen(),
              ),
            ],
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          memoNotifierProvider.overrideWith(
            () => notifier ?? fakeNotifier,
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets(
      '設定画面のタイトルが表示される',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('設定'), findsOneWidget);
      },
    );

    testWidgets(
      'セクションタイトルが表示される',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(
          find.text('データ / メモル星へ送られます'),
          findsOneWidget,
        );
        expect(find.text('サポート'), findsOneWidget);
      },
    );

    testWidgets(
      'データ設定項目が表示される',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(
          find.text('バックアップ / 復元'),
          findsOneWidget,
        );
        expect(
          find.text('すべてのメモを削除'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'バックアップ成功時にSnackBarが表示される',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(
          find.text('バックアップ / 復元'),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('保存しました！'),
          findsOneWidget,
        );
        expect(fakeNotifier.backupCalled, true);
      },
    );

    testWidgets(
      'バックアップ失敗時にエラーSnackBarが表示される',
      (tester) async {
        final failNotifier = FailBackupNotifier();
        await tester.pumpWidget(
          buildSubject(notifier: failNotifier),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.text('バックアップ / 復元'),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('保存に失敗しました'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '削除をタップするとダイアログが表示される',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(
          find.text('すべてのメモを削除'),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('キャンセル'),
          findsOneWidget,
        );
        expect(find.text('削除'), findsOneWidget);
      },
    );

    testWidgets(
      '削除ダイアログでキャンセルすると削除されない',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(
          find.text('すべてのメモを削除'),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('キャンセル'));
        await tester.pumpAndSettle();

        expect(fakeNotifier.deleteAllCalled, false);
      },
    );

    testWidgets(
      '削除を選択するとdeleteAllが呼ばれる',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(
          find.text('すべてのメモを削除'),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('削除'));
        await tester.pumpAndSettle();

        expect(fakeNotifier.deleteAllCalled, true);
        expect(
          find.text('すべてのメモを削除しました'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '戻るボタンが表示される',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(
          find.byIcon(Icons.arrow_back_ios),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'スクロールで下部の項目が表示される',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // 下にスクロール
        await tester.dragUntilVisible(
          find.text('クラッシュテスト'),
          find.byType(ListView),
          const Offset(0, -200),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('クラッシュテスト'),
          findsOneWidget,
        );
      },
    );
  });
}
