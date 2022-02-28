## Syobo-QL
しょぼいSQLっぽい言語  
SQLの完全なサブセットではなく、各句は実際の実行順に並んでいる  
常にWHERE句を記述しなければならず、条件指定がない場合はUNCONDITINALというトークンを置いて明示する必要がある。

## 例
```sql
FROM Todo JOIN Staff USING(staffId)
WHERE staffId = 1
GROUP BY deadline
SELECT COUNT(*),deadline
ORDER BY deadline ASC
LIMIT 3;
```

## しょぼいポイント
 - SQLのトークンは大文字じゃないと受け付けない
 - SELECT文のFROM句で指定できるテーブルは一つだけ（複数のテーブルを結合して一つのテーブルにすることは可能）
 - JOINの条件指定で使えるのはUSINGのみ（ONはダメ）
 - USINGに使えるカラムは一個だけ
 - 外部結合はできない
 - WHERE句で使える条件は一個だけ
 - WHERE句の条件の右辺は必ずリテラル
 - 使える集約関数はCOUNTとMAXとMINだけ
 - ORDER BYは昇順降順を常に明示する必要がある
 - LIMIT句でオフセットの指定はできない
 - その他、できるか微妙そうなことは大抵できない