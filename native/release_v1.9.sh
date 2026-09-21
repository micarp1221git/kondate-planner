#!/bin/bash
# 献立まるっとプランナー iOS v1.9(build23) を、AdMobバナー広告（本番ID）込みでビルド→App Store Connectへアップロードする（2026-09-22・iOS 27 の UIScene 対応＝Capacitor 8.5.0）
# 打つのはこれ1本:  bash ~/git/kondate-planner/native/release_v1.9.sh
# 中身: バージョン上げ → www同期 → cap sync → 署名ありアーカイブ → export+upload（APIキー方式・README「TestFlightアップロード」と同じ）
set -e
cd "$(dirname "$0")"
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
KEYDIR="$HOME/.appstoreconnect/private_keys"; KEY="$(ls "$KEYDIR"/AuthKey_*.p8 | head -1)"; KID="$(basename "$KEY" .p8 | sed 's/AuthKey_//')"
ISS="$(grep -o 'authenticationKeyIssuerID [0-9a-f-]*' README.md | head -1 | awk '{print $2}')"
[ -f "$KEY" ] && [ -n "$ISS" ] || { echo "❌ 鍵かIssuerIDが見つからない"; exit 1; }
LOG="$HOME/Desktop/献立v1.9_ビルドログ.txt"; : > "$LOG"
# バージョンは既に 1.9/23 に上げ済み（2026-09-22）
echo "① バージョン: $(grep -m1 MARKETING_VERSION ios/App/App.xcodeproj/project.pbxproj) / $(grep -m1 CURRENT_PROJECT_VERSION ios/App/App.xcodeproj/project.pbxproj)"
./copy-www.sh >>"$LOG" 2>&1; echo "② www同期: 本番バナーID=$(grep -c 3051733341 www/index.html) / admobプラグイン=$(grep -c admob package.json)"
npx cap sync ios >>"$LOG" 2>&1; echo "③ cap sync OK"
rm -rf build/App.xcarchive build/export
echo "④ アーカイブ中（3〜6分）..."; xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Release -destination "generic/platform=iOS" -archivePath build/App.xcarchive archive -allowProvisioningUpdates -authenticationKeyPath "$KEY" -authenticationKeyID "$KID" -authenticationKeyIssuerID "$ISS" >>"$LOG" 2>&1 && echo "   ✅ アーカイブOK" || { echo "   ❌ アーカイブ失敗 → $LOG"; exit 1; }
echo "⑤ アップロード中（2〜5分）..."; xcodebuild -exportArchive -archivePath build/App.xcarchive -exportPath build/export -exportOptionsPlist ios/App/archive/uploadOptions.plist -allowProvisioningUpdates -authenticationKeyPath "$KEY" -authenticationKeyID "$KID" -authenticationKeyIssuerID "$ISS" >>"$LOG" 2>&1 && echo "   ✅ アップロードOK（Appleの処理待ち・10〜30分）" || { echo "   ❌ アップロード失敗 → $LOG"; exit 1; }
echo "⑥ 次: python3 ~/git/MIKA_VAULT/06_Projects/20260721_献立アプリUIUX監査/tools/asc.py builds  でVALIDを確認 → create_version 1.9 → set_build → submit（AIがやる）"
