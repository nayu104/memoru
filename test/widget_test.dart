import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memomemo/core/app.dart';
import 'package:memomemo/core/application/app_info_provider.dart';

void main() {
  testWidgets('😄初回起動時はオンボーディングが表示されること', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isFirstLaunchProvider.overrideWithValue(true)],
        child: const MemoMemoApp(),
      ),
    );

    // 描画を待つ
    await tester.pumpAndSettle();

    // オンボーディング画面では追加ボタンとタイトルが表示されないことを確認
    expect(find.text('気分でメモメモ'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);

    // オンボーディングの最初のページのテキストが表示されていることを確認
    expect(find.text('今の気分を記録しよう'), findsOneWidget);
  });

  testWidgets('2回目以降はメモ一覧が表示されること', (WidgetTester tester) async {
    // 1. アプリをビルド（isFirstLaunch: false を渡す）
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isFirstLaunchProvider.overrideWithValue(false)],
        child: const MemoMemoApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 検証: メモ追加ボタン（FAB）が見つかるか？
    expect(find.byIcon(Icons.add), findsOneWidget);
    // オンボーディングの文字は見つからないはず
    expect(find.text('今の気分を記録しよう'), findsNothing);
  });
}
