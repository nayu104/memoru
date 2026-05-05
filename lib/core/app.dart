import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memomemo/core/app_theme.dart';
import 'package:memomemo/features/screens/memo_list_screen.dart';
import 'package:memomemo/features/screens/new_memo_modal.dart';
import 'package:memomemo/features/screens/onboarding_screen.dart';
import 'package:memomemo/features/screens/setting_screen.dart';

class MemoMemoApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MemoMemoApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: isFirstLaunch ? '/onboarding' : '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const SelectionArea(child: MemoListScreen()),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) {
            final fromSettings =
                state.uri.queryParameters['fromSettings'] == 'true';
            return SelectionArea(
              child: OnboardingScreen(fromSettings: fromSettings),
            );
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SelectionArea(child: SettingScreen()),
        ),
        GoRoute(
          path: '/new',
          pageBuilder: (context, state) => MaterialPage(
            fullscreenDialog: true,
            child: const SelectionArea(child: NewMemoModal()),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // 右上の帯を消す
      title: '気分×色メモ',
      theme: appTheme, // 作成したテーマを適用
      routerConfig: router,
    );
  }
}
