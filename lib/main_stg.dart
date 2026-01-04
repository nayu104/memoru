import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/flavors.dart';
import 'main.dart' as runner;

Future<void> main() async {
  // .envファイルをロード
  await dotenv.load(fileName: ".env");

  // 検証環境(stg)のフラグを立てる
  FlavorClass.appFlavor = Flavor.stg;

  // アプリ本体を起動
  await runner.main();
}
