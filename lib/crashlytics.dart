import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

Future<void> setupCrashlytics() async {
  // Flutter フレームワーク内のエラーを全てキャッチ
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  // フレームワークで捕捉されなかった非同期エラー
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

/// ログを出力
void logCrashlytics(String message) {
  FirebaseCrashlytics.instance.log(message);
}

/// アプリを強制的にクラッシュさせる
void crashApp(String message) {
  FirebaseCrashlytics.instance.crash();
}
