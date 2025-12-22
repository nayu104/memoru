import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memomemo/core/app_theme.dart';
import 'package:memomemo/core/router/app_router.dart';

class MemoMemoApp extends ConsumerWidget {
  const MemoMemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false, // 右上の帯を消す
      title: '気分×色メモ',
      theme: appTheme, // 作成したテーマを適用
    );
  }
}
