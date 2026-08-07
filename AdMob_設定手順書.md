# 献立アプリ バナー広告（AdMob）設定手順書（2026-08-07準備完了）

## いまの状態

- アプリ下部の小さいバナー広告のコードは**組み込み済み**（ネイティブアプリ版のみ表示・Web版には出ない）
- いまは**Google公式のテスト広告ID**が入っている。このままビルドするとテスト広告が出る
- 非パーソナライズ広告（npa）設定なので、「トラッキング許可」ダイアログ（ATT）の実装は不要

## みかさんがやること（2つだけ・計15分）

### ① AdMobアカウントを開設する（10分）

1. https://admob.google.com を開き、Googleアカウントでログイン
2. 案内に従ってアカウント作成（国: 日本／支払い受け取り情報は後からでも可）

### ② アプリを登録してIDを4つ取る（5分）

1. AdMob管理画面 →「アプリ」→「アプリを追加」
2. **iOS**を選択 →「アプリはApp Storeに公開済みですか?」→ 公開済みなら検索して選択、未公開なら「いいえ」で名前登録（献立まるっとプランナー）
3. できたアプリの「アプリID」（`ca-app-pub-〜1234567890` の形）を控える
4. そのアプリ内で「広告ユニット」→「バナー」を作成 → 「広告ユニットID」（`ca-app-pub-〜/1234567890` の形）を控える
5. **Android**でも同じことをする（アプリID＋バナーユニットID）

**→ 取れた4つのIDを、Discordでそのまま貼ってください。差し替え・ビルド・再申請はAIがやります。**

## AIがやること（IDを受け取ったら）

差し替え箇所は3ファイル:

| ファイル | 差し替えるもの |
|---|---|
| [index.html](index.html) の `ADMOB_CONFIG` | バナーユニットID（iOS/Android）＋ `isTesting: false` に |
| [native/ios/App/App/Info.plist](native/ios/App/App/Info.plist) の `GADApplicationIdentifier` | iOSアプリID |
| [native/android/app/src/main/AndroidManifest.xml](native/android/app/src/main/AndroidManifest.xml) の `APPLICATION_ID` | AndroidアプリID |

その後: `./copy-www.sh && npx cap sync` → ビルド → ストアへ新バージョン提出（App Store Connectで「広告を含む」の申告を「はい」に変える）。

## 注意メモ

- いま審査中のiOS v1.2には広告は**入っていない**（このコードは次のバージョンから）
- 広告が実際に配信され始めるまで、アカウント開設後に数日かかることがある（Google側の審査）
- 収益受け取りには住所確認（郵送PINコード）と支払い情報の登録が後で必要
- 将来パーソナライズ広告に切り替えて単価を上げたくなったら、ATT（トラッキング許可ダイアログ）の実装が必要（AIに言えば実装します）
