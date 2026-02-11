import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memomemo/features/screens/memoru_star_screen.dart';

void main() {
  group('MemoruStarScreen', () {
    testWidgets('画面が正しく描画される', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: MemoruStarScreen()),
      );

      // メッセージが表示される
      expect(
        find.text('みんなの感情の気配が、この星の天気を与えています'),
        findsOneWidget,
      );
      expect(
        find.text('薄い霧が、想いを包み込んでいます。'),
        findsOneWidget,
      );
    });

    testWidgets('統計情報が表示される', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: MemoruStarScreen()),
      );

      expect(find.text('214'), findsOneWidget);
      expect(find.text('降り積もった想い'), findsOneWidget);
      expect(find.text('穏やか'), findsOneWidget);
      expect(find.text('激しい'), findsOneWidget);
      expect(find.text('58%'), findsOneWidget);
      expect(find.text('42%'), findsOneWidget);
    });

    testWidgets(
      '戻るボタンが表示される',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(home: MemoruStarScreen()),
        );

        expect(
          find.byIcon(Icons.arrow_back_ios),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '戻るボタンをタップすると前の画面に戻る',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        var popped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MemoruStarScreen(),
                    ),
                  );
                },
                child: const Text('Go'),
              ),
            ),
            navigatorObservers: [
              _PopObserver(onPop: () => popped = true),
            ],
          ),
        );

        // 画面遷移
        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        // 戻るボタンをタップ
        await tester.tap(
          find.byIcon(Icons.arrow_back_ios),
        );
        await tester.pumpAndSettle();

        expect(popped, true);
      },
    );

    testWidgets(
      'グラデーション背景が存在する',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(home: MemoruStarScreen()),
        );

        // グラデーション付きのContainerが存在する
        final containers = tester.widgetList<Container>(
          find.byType(Container),
        );
        final hasGradient = containers.any(
          (c) {
            final deco = c.decoration;
            if (deco is BoxDecoration) {
              return deco.gradient is LinearGradient;
            }
            return false;
          },
        );
        expect(hasGradient, true);
      },
    );

    testWidgets(
      'BackdropFilter が使用されている',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(home: MemoruStarScreen()),
        );

        expect(
          find.byType(BackdropFilter),
          findsWidgets,
        );
      },
    );
  });
}

class _PopObserver extends NavigatorObserver {
  _PopObserver({required this.onPop});

  final VoidCallback onPop;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop();
    super.didPop(route, previousRoute);
  }
}
