# 検証環境 (Staging) で実行
# main_stg.dart を起動ファイルとして指定
run-stg:
	fvm flutter run -t lib/main_stg.dart

# 本番環境 (Production) で実行
# main_prod.dart を起動ファイルとして指定
run-prod:
	fvm flutter run -t lib/main_prod.dart

# ビルド用コマンド（リリース用）
build-ios-prod:
	fvm flutter build ipa -t lib/main_prod.dart --release

build-android-prod:
	fvm flutter build appbundle -t lib/main_prod.dart --release