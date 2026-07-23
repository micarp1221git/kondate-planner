# 献立まるっとプランナー iOS版（Capacitorラッパー）

本体はリポ直下のPWA（index.html ほか）。このフォルダはそれをiOSアプリに包む器。
早口言葉アプリ（hayakuchi-challenge/native/）と同じ型。

## 仕組み
- `copy-www.sh` … リポ直下のPWAファイルを `www/` にコピー（www/ はgit管理外・生成物）
- Capacitor 8（SPM方式・CocoaPods不要）＋ @capacitor/local-notifications
- ネイティブ価値: 毎朝7:30「今日の3品」ローカル通知（index.html内・ネイティブ実行時のみ発動）
- Bundle ID: `com.experisent.kondate`
- **v1は完全無料・課金要素なし**（2026-07-21 みかさん確定。課金はリリース後の実測を見て判断）

## 本体を更新したらiOSに反映する手順
```sh
cd native
./copy-www.sh
npx cap sync ios
npx cap open ios   # Xcodeが開く → 実行 or Archive
```

## 審査提出時の必須設定（忘れ厳禁）
- App Store Connect で **EU配信オフ＋非trader申告**（住所・電話の公開回避。詳細: Vault `06_Projects/20260628_AppleDeveloper組織登録/経緯と設計.md`）
- 審査メモ: 「献立の自動提案・オフライン動作は端末内で完結。アカウント不要」

## TestFlightアップロード（APIキー方式・2026-07-23確立）

Xcodeのサインインセッション切れ（数時間で失効）に依存しない恒久方式。

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
# 1) データ更新時: ./copy-www.sh && npx cap sync ios
# 2) ビルド番号を上げる: project.pbxproj の CURRENT_PROJECT_VERSION（2箇所）
# 3) アーカイブ（署名なし）
xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Release \
  -destination "generic/platform=iOS" -archivePath build/App.xcarchive archive CODE_SIGNING_ALLOWED=NO
# 4) エクスポート＋アップロード（クラウド署名はAdminロールのAPIキーが必須。App Managerでは Cloud signing permission error になる）
xcodebuild -exportArchive -archivePath build/App.xcarchive -exportPath build/export \
  -exportOptionsPlist ios/App/archive/uploadOptions.plist -allowProvisioningUpdates \
  -authenticationKeyPath ~/.appstoreconnect/private_keys/AuthKey_V2DJLMWAM3.p8 \
  -authenticationKeyID V2DJLMWAM3 -authenticationKeyIssuerID 45f6c478-1907-47e6-9f78-b2e43eda8316
# 5) 実物確認（アップロード完了の自己申告を信用しない）: ASC APIでbuildsのprocessingStateがVALIDになるのを見る
```

- 鍵: `~/.appstoreconnect/private_keys/AuthKey_V2DJLMWAM3.p8`（600権限・Adminロール・失効はASC「ユーザとアクセス」→「統合」から）
- 早口言葉アプリ（hayakuchi-challenge/native）も同じ方式でOK
