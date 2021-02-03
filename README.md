# ACP bot

## これはなに

項書き換え系のChurch-Rosser性や正規形の一意性を判定するツール"ACP"のTwitterインターフェースです．

## インストール

Standard ML New Jersey, minisat, yices2, acp を別途インストールする必要があります．Twitter API の利用申請も必要です．

## 実行

`example.env`を書き換えて，以下のコマンドを実行．

```
$ cp example.env .env
$ bundle install --path vendor/bundle
$ bundle exec ruby main.rb
```
