import 'flavors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static const String _apiBaseUrlKey = 'apiBaseUrl';

  // 検証環境用設定
  static Map<String, dynamic> get _stgConfig => {
    _apiBaseUrlKey: dotenv.env['API_BASE_URL'] ?? '',
  };

  // 本番環境用設定
  static Map<String, dynamic> get _prodConfig => {
    _apiBaseUrlKey: dotenv.env['API_BASE_URL'] ?? '',
  };

  static Map<String, dynamic> get _config {
    switch (FlavorClass.appFlavor) {
      case Flavor.stg:
        return _stgConfig;
      case Flavor.prod:
        return _prodConfig; // getter呼び出しになるのでOK
      default:
        return _stgConfig;
    }
  }

  // 外部からアクセスするためのGetter
  static String get apiBaseUrl => _config[_apiBaseUrlKey] as String;
}
