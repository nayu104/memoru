enum Flavor {
  stg, // 検証環境
  prod, // 本番環境
}

class FlavorClass {
  static Flavor? appFlavor;

  static String get flavorName {
    // enumの機能として .name プロパティが自動的に用意されており、
    // "stg" や "prod" といった文字列を取得できる
    return appFlavor?.name ?? '';
  }
}
