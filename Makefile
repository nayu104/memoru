# 開発環境で実行
run-dev:
	fvm flutter run

# ビルド用コマンド（リリース用）
build-ios:
	fvm flutter build ipa --release

build-android:
	fvm flutter build appbundle --release

# テスト
test:
	fvm flutter test

# テスト（カバレッジ付き）
test-coverage:
	fvm flutter test --coverage

# 静的解析
analyze:
	fvm flutter analyze

# コード生成
gen:
	fvm flutter pub run build_runner build --delete-conflicting-outputs
