## Syobo-QL
しょぼいSQLっぽい言語  
SQLの完全なサブセットではなく、各句は実際の実行順に並んでいる  
常にWHERE句を記述しなければならず、条件指定がない場合はUNCONDITINALというトークンを置いて明示する必要がある。

## 例
```sql
FROM Todo JOIN Staff USING(staffId)
WHERE staffId = 1
GROUP_BY deadline
SELECT COUNT(*),deadline
ORDER_BY deadline ASC
LIMIT 3;
```

## しょぼいポイント
 - JOINの条件指定で使えるのはUSINGのみ（ONはダメ）
 - USINGに使えるカラムは一個だけ
 - 外部結合はできない
 - WHERE句で使える条件は一個だけ
 - WHERE句の条件の右辺は必ずリテラル
 - 使える集約関数はCOUNTとMAXとMINだけ
 - LIMIT句でオフセットの指定はできない
 - その他、できるか微妙そうなことは大抵できない