import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memomemo/features/widgets/setting_ui_components.dart';

void main() {
  group('SectionTitle', () {
    testWidgets('タイトルが表示される', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionTitle(title: 'テストセクション'),
          ),
        ),
      );

      expect(find.text('テストセクション'), findsOneWidget);
    });
  });

  group('SettingTile', () {
    testWidgets('アイコンとタイトルが表示される', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingTile(
              icon: Icons.backup,
              title: 'バックアップ',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('バックアップ'), findsOneWidget);
      expect(find.byIcon(Icons.backup), findsOneWidget);
      expect(
        find.byIcon(Icons.chevron_right),
        findsOneWidget,
      );
    });

    testWidgets('タップでコールバックが呼ばれる', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingTile(
              icon: Icons.settings,
              title: 'テスト',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('テスト'));
      expect(tapped, true);
    });

    testWidgets('subtitle が表示される', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingTile(
              icon: Icons.info,
              title: 'バージョン',
              subtitle: '1.0.0',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('バージョン'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets(
      'titleColor が指定された場合に適用される',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingTile(
                icon: Icons.delete,
                title: '削除',
                titleColor: Colors.red,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('削除'), findsOneWidget);

        // タイトルのテキストウィジェットを確認
        final text = tester.widget<Text>(find.text('削除'));
        expect(text.style?.color, Colors.red);
      },
    );

    testWidgets(
      'subtitle が null の場合は表示されない',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingTile(
                icon: Icons.star,
                title: 'レビュー',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('レビュー'), findsOneWidget);
        // ListTile の subtitle は null なので
        // 余分なテキストは表示されない
        final listTile = tester.widget<ListTile>(
          find.byType(ListTile),
        );
        expect(listTile.subtitle, isNull);
      },
    );
  });
}
