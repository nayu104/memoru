import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

/// Firebase のモックを設定する
/// テストの setUp で呼び出す
Future<void> setupFirebaseMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();

  await Firebase.initializeApp();
}
