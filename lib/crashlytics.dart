import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class Crashlytics {
  static Future<void> setup() async {
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
  static log(String message) {
    FirebaseCrashlytics.instance.log(message);
  }

  /// アプリを強制的にクラッシュさせる
  static crash(String message) {
    FirebaseCrashlytics.instance.crash();
  }
}
