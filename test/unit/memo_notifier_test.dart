import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memomemo/core/domain/memo.dart';
import 'package:memomemo/core/domain/mood.dart';
import 'package:memomemo/core/provider/memo_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // SharedPreferencesのモック（偽物）を準備
  // これがないと "MissingPluginException" エラー
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  test('初期状態は空であること', () {
    // final containar = ProviderContainer();
  });
}
