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

## 🚨 2026-08-12 v1.3(build17)で学んだこと（審査提出の追記）

- **AdMobプラグイン入りだと、従来手順（`CODE_SIGNING_ALLOWED=NO`でアーカイブ）は通らない**: 埋め込みの `GoogleMobileAds.framework`/`UserMessagingPlatform.framework` が無署名のまま残り、export時のクラウド署名が「not properly signed (90035)」で失敗する。v1.3では `npm remove @capacitor-community/admob` で除去して通した
- ✅ **解決済み（2026-08-13深夜・ローカル実証）**: **アーカイブを署名ありで行う**と通る。`CODE_SIGNING_ALLOWED=NO` を外し、アーカイブにも認証キー3点（-allowProvisioningUpdates -authenticationKeyPath/KeyID/IssuerID）を付けるだけ。検証= destination=export のローカルexportで ipa を作り、App本体「Apple Distribution: EXPERISENT」・フレームワークにTeamIdentifier入りを codesign で確認（アップロードはしていない）。**広告版はこの手順でそのまま提出できる**。プラグイン再追加済みブランチ= `admob-signing-test`（ローカル）
- **審査提出の後半（バージョン作成→ビルド添付→提出）はASC APIで全自動化できた**: 手順スクリプト＝Vault `06_Projects/20260721_献立アプリUIUX監査/tools/asc.py`（app/builds/versions/create_version/set_build/set_notes/rs_create/rs_add/rs_submit）。⚠️旧 `appStoreVersionSubmissions` はCREATE禁止になっている＝**reviewSubmissions（rs_*）を使う**
- 💎 **アプリ側ファイルを直したら「いつ申請するか」をその場で決める**: v1.2提出後の変更が未申請のまま4日置かれ、みかさんの「アップデートしても変わらない」で発覚した
