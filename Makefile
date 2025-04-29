# 依存関係の更新
.PHONY: upgrade-deps
upgrade-deps:
	flutter pub get

# 依存関係の更新（メジャーバージョンも含む）
.PHONY: upgrade-deps-major
upgrade-deps-major:
	flutter pub upgrade --major-versions

# 依存関係の古いバージョンを確認
.PHONY: check-outdated-deps
check-outdated-deps:
	flutter pub outdated

# ビルド（Android）
.PHONY: build-android
build-android:
	export $$(cat .env | grep -v '^#' | xargs) && flutter build apk --debug

# ビルド（iOS）
.PHONY: build-ios
build-ios:
	flutter build ios --debug

# 本番ビルド（Android）
.PHONY: build-android-release
build-android-release:
	export $$(cat .env | grep -v '^#' | xargs) && flutter build apk --release

# 本番ビルド（iOS）
.PHONY: build-ios-release
build-ios-release:
	flutter build ios --release

# デバッグ実行（Android）
.PHONY: run-android
run-android:
	flutter run -d android

# デバッグ実行（iOS）
.PHONY: run-ios
run-ios:
	flutter run -d ios

# クリーンアップ
.PHONY: clean
clean:
	flutter clean
	rm -rf build/
	rm -rf .dart_tool/
	rm -rf .packages
	rm -rf .flutter-plugins
	rm -rf .flutter-plugins-dependencies
	rm -rf pubspec.lock

# コードフォーマット
.PHONY: format
format:
	flutter format lib/

# コード分析
.PHONY: analyze
analyze:
	flutter analyze

# アプリアイコンを生成
.PHONY: generate-icons
generate-icons:
	flutter pub get
	dart run flutter_launcher_icons

# .env をBase64でエンコード
.PHONY: encode-base64-env
encode-base64-env:
	cat .env | base64 -w 0

# google-services.json をBase64でエンコード
.PHONY: encode-base64-google-services-json
encode-base64-google-services-json:
	cat android/app/google-services.json | base64 -w 0

# GoogleService-Info.plist をBase64でエンコード
.PHONY: encode-base64-google-service-info-plist
encode-base64-google-service-info-plist:
	cat ios/Runner/GoogleService-Info.plist | base64 -w 0

# bsam-key.jks をBase64でエンコード
.PHONY: encode-base64-bsam-key-jks
encode-base64-bsam-key-jks:
	cat android/bsam-key.jks | base64 -w 0

# key.properties をBase64でエンコード
.PHONY: encode-base64-key-properties
encode-base64-key-properties:
	cat android/key.properties | base64 -w 0

# bsam-key.jks の確認
.PHONY: check-bsam-key
check-bsam-key:
	keytool -list -v -keystore android/bsam-key.jks
