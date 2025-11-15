import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'package:memomemo/features/memo/ui/screens/memo_list_screen.dart';

class MemoMemoApp extends StatelessWidget {
  const MemoMemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '気分×色メモ',
      theme: appTheme,
      home: const MemoListScreen(),
    );
  }
}
