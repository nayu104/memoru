import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memomemo/core/domain/memo.dart';
import 'package:memomemo/core/provider/memo_state.dart';
import 'package:memomemo/features/screens/setting_screen.dart';

import '../mock_firebase.dart';

class FakeSettingNotifier extends MemoNotifier {
  bool deleteAllCalled = false;

  @override
  Future<List<Memo>> build() async => [];

  @override
  Future<void> deleteAll() async {
    deleteAllCalled = true;
    state = const AsyncData([]);
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
          find.text('すべてのメモを削除'),
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
  });
}
