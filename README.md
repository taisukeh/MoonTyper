# 月配列エミュレータ

月配列でタイピングゲームを遊ぶためのエミュレータです。

月配列の入力キーを、ローマ字入力キーに変換します。

入力する文字が確定した時点ではじめて対応するローマ字のキーを発火します。濁点、半濁点は清音に後置の場合、「は」を入力した時点では「は」なのか「ば」なのか「ぱ」なのか確定しないため、「は」の入力後に何かしらのキーを押した際に初めて「は」（もしくは濁点を押した場合は「ば」）を出力します。


## インストール

TBD.

## 使い方

起動後アクセシビリティで

## 設定ファイル

ホームディレクトリの `~/TsukiEmulator` 以下に [YAML](https://ja.wikipedia.org/wiki/YAML)形式で月配列の定義を置きます。

```
name: "<表示名>"
keyboard: "<JIS or US>"
keymap:
  # 左が月配列で打つキー名、右がローマ字入力のキー
  "kf": "a"
  "df": "a"
  "i": "i"
  "j": "u"
  "du": "e"
n```

# SandS

- `Space → Space`
- `Space+A → Shift+A`, `Space+B → Shift+B`
- `Control+Space → Control+Space`, `Alt+Space → Alt+Space`

## Install

[download SandS.app.zip](https://github.com/ToQoz/SandS/releases/download/v1.0/SandS.app.zip)

## Tested on

- OSX El Capitan 10.11.6
- macOS Sierra 10.12.3
