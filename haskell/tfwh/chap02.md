# 第2章 式, 型, 値

既に読書会開始から3時間半たっており、疲労から眠かった。また途中でちょっと退席した。ので、雑。

## 2.2 名前と演算子

### セクションとλ抽象式

なまえをつけよ。との主張。

## 2.3 評価

### ⊥

2.1 では以下のように書かれている

> ```
> ghci > 1 `div` 0
> *** Exception: divide by zero
> ```
>  
> GHCi はエラーメッセイージを返している. いったい ' 1 ''div'' 0' の値は何か. この値は特別な値で数学記号としては⊥を書き「ボトム(bottom)」と読む. Haskellではこの値に `bottom` ではなく `undefined` という名前が定義済みである

その上で。

> Haskell では遅延評価を採用しているので, 非正格関数を定義できる. これが, Haskellが非正格関数型言語と呼ばれる理由である.

> ```
> data Bool = False | True
> ```
> 
> 宣言によりBool型にはFalse, True という2つのデータ構成子がある. Bool型には2つではなく, 3つの値がある.それは False, True, undefined :: Bool である. 

> 
> to の定義は完全に正しい形式であるが, to True を評価しようとすると, GHCi は無限ループに陥る. したがって, その値は⊥であり, その型はBoolである。

Haskellの関数は部分関数なので未定義領域があるので
つつけば 例外が起きる。

じゃあ非停止も ⊥なの？

→Haskell の気分としては、書ける（型つけできる）んだけれども、値を持たないのはおかしいと考える

> このように全ての型に ⊥ という値があることを認識しておこう.

なので、値 undefined がある。

評価が定まらないものをボトム(⊥)と呼ぶ。これには

* 例外 (undefined) 
* 非停止

が含まれる。

## 2.4 型と型クラス

多相関数と型変数

> では (+) の型はどのような型か. 以下はその候補である.
>
> ```
> (+) :: Int -> Int -> Int
> (+) :: Float -> Float -> Float
> (+) :: a -> a -> a
> ```
> 
> 最初の2つは特定の型でしかつかいないので不便である. 一方, 最後のものは一般化しすぎている.

> 解は **型クラス** を導入することである
>
> ```
> (+) :: Num a => a -> a -> a->
> ```

型変数は、その型の使われ方を（静的型チェックの世界にて動的に）確認する。メタな世界での動的型付けと言えるかもしれない。
メタな世界でも変数に型を付けたい時、すなわち型変数に型を付けたい時に型の型である型クラスが登場する。

……という説明に読めた(動的型付け言語をバックボーンにもつわたしの色メガネかもしれない)。

うまい説明だな、とおもった。

## 2.5 値の表示

Text 使っても結局これのせいで String から逃げられない

## 2.6 モジュール

コード例が「`>`を省略するのが本書のルール」が適用されて、文芸スクリプトじゃないように見えるのに、そのルールが適用されている前提だから

> さらにこのファイルを `CommonWords.lhs` というファイルに格納しなければならない(これは文芸的スクリプトを用いる場合で, 用いないときは `CommonWords.hs` とする)

となるのは紛らわしいというか、カッコの中と外をスワップすればいいんじゃまいか？
(シーケンシャルに読まれることを前提にして良い「教科書」だからゆるされるのか？)


## 2.7 Haskell のレイアウト

> ブレースとセミコロンはレイアウトを制御するためにのみ用いられ, Haskell の式としての意味はない. do記法以外でもつかえる

> キーワード where, do, let の直後でブレースを開かなか立ち上場合には, レイアウトルール(もしくは **オフサイド** ルールが適用される.

モジュール宣言の where はオフサイドルールが適用されない例外になっている

## 練習問題A

> 優先順位に関する問題である. この問題は _Guardian_ 紙の　Chris Maslanka のパズル欄にあったものである.
>
> 2たす2のはんぶんは2かそれとも3か.

### 解答

```
Prelude> let x = 2 + 2 / 2 in (x == 2) || (x == 3) 
True
```

ひどい。

プログラミング言語としては、

```
(2 + 2 / 2) = 2 or 3
```

と書けるものは（多分）ないので書き下すには違和感がある。


