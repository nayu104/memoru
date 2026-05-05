import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app.dart';
import 'core/application/app_info_provider.dart';
import 'core/data/local_memo_repository.dart';
import 'core/utils/crashlytics.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupCrashlytics();

  // データの保存場所 (SharedPreferences) を準備
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(
    ProviderScope(
      overrides: [
        memoRepositoryProvider.overrideWithValue(LocalMemoRepository(prefs)),
        isFirstLaunchProvider.overrideWithValue(isFirstLaunch),
      ],
      child: const MemoMemoApp(),
    ),
  );
}
