使用RDBMS时，最常见的系统结构客户端/服务器类型（C/S类型）这种结构。

RDBMS也是一种服务器，它能够从保存在硬盘上的数据中读取数据并返回，还可以把数据变更为指定内容。

## Data definition Language

- CREATE
- DROP
- ALTER

## Data Manipulation Language

- SELECT
- INSERT
- UPDATE
- DELETE

## Data Control Language

- COMMIT
- ROLLBACK
- GRANT
- REVOKE

SQL用单引号(')表示字符串

可以像`CHAR(10)`或者`CHAR(200)`这样，在括号中指定该列可以存储的字符串的长度（最大长度）。字符串超出最大长度的部分是无法输入到该列中的。比如`CHAR(8)`,`abc`会以`abc_____`存储。

同`CHAR`一样，`VARCHAR`也是用来指定储存字符串的列的数据类型（字符串类型），也可以通过括号内的数字来指定字符串的长度（最大长度）。但该类型的列是以可变长字符串的形式来保存字符串的。

主键是可以唯一确定一行数据的列。

```sql
ALTER TABLE Product ADD COLUMN product_name_pinyin VARCHAR(100)
```

```sql
begin transaction

insert ...
insert ...

commit
```

如果使用星号的话，就无法设定显示列的显示顺序了。

在使用`DISTINCT`时，`NULL`也被视为一类数据。`NULL`存在多行时，也会被视作为一条`NULL`数据。

`DISTINCT`关键字只能用在第一个列名之前。

SQL语句也可以使用运算表达式。

```sql
SELECT product_name, sale_price, sale_price * 2 AS "SALE_PRICE_X2"
FROM Product
```

所有包含`NULL`的**计算**，结果肯定是`NULL`。

```sql
SELECT product_name, product_type, regist_date
FROM Product
WHERE regist_date < '2009-09-27'
```

不能对`NULL`使用比较运算符

```sql
SELECT product_name, purchase_price
FROM Product
WHERE purchase_price IS NULL
```

```sql
SELECT product_name, product_type, sale_price
FROM Product
WHERE NOT sale_price >= 1000;
```

`AND`运算符的优先级高于`OR`运算符。想要优先执行`OR`运算符时可以使用括号。

`NULL`既不是真也不是假，SQL中逻辑运算被称为**三值逻辑**。

```sql

SELECT COUNT(purchase_price)
FROM Product;

```

`purchase_price`列中有两行数据是`NULL`，因此并不应该计算这两行。

`COUNT(*)`会得到包含`NULL`的数据行数，而`COUNT`会得到`NULL`之外的数据行数。但是`COUNT(*)`并不会排除`NULL`。

`MAX/MIN`函数几乎适用于所有数据类型的列。`SUM/AVG`函数只适用与数值类型的列。

```sql
SELECT COUNT(DISTINCT product_type)
FROM Product
```

当聚合键中包含`NULL`中，也会将`NULL`作为一组特定的数据。

SELECT子句中只能存在以下三种元素。

- 常数
- 聚合函数
- `GROUP BY`子句中指定的列名字

`GROUP_BY`的显示结果是无序的

子句的书写顺序
`SELECT -> FROM -> WHERE -> GROUP BY -> HAVING -> ORDER BY`

`ORDER BY`中也可以使用聚合函数
```sql
SELECT product_type, COUNT(*)
FROM Product
GROUP BY product_type
ORDER BY COUNT(*)
```

事务是对表中数据进行更新的单位。事务就是需要在同一个处理单元中执行的一系列更新处理的集合。

`COMMIT`是提交事务包含的全部更新处理的结束命令，相当于文件处理中的覆盖保存。一旦提交，就无法回复到事务开始前的状态了。因此，在提交之前一定要确定是否真的需要进行这些更新。

实际上，几乎所有的数据库产品的事务都无需开始指令。这是因为大部分情况下，事务在数据库连接建立时就已经悄悄开始了，并不需要用户再明确发出开始指令。

## 原子性

原子性是指在事务结束的时候，其中所包含的更新处理要么全部执行，要么完全不执行，也就是要么占有一切要么一无所有。

## 一致性

一致性指的是事务中包含的处理要满足数据库提前设置的约束，如主键约束或者`NOT NULL`约束等。例如，设置了`NOT NULL`约束的列是不能更新为`NULL`的，试图插入主键约束的记录就会出错，无法执行，对事务来说，这些不合法的SQL会被回滚。

## 隔离性

隔离性指的是保证不同事务之间互补干扰的特性。该特性保证了事务之间互不相干的特性。此外，在某个事务中进行的更改，在该事务结束之前，对其他事务而言是不可见的。

## 持久性
指的是事务结束后，`DBMS`能够保证该时间点的数据状态会被保存的特性。即使由于系统故障导致数据丢失，数据库也一定能通过某种手段进行修复。

标量子查询则有一个特殊的限制，那就是必须而且只能返回1行1列的结果，也就是返回表中某一行的某一列的值

```sql
SELECT product_id, product_name, sale_price
FROM Product
WHERE sale_price > (SELECT AVG(sale_price) FROM Product)
```

标量子查询在能够使用常数或者列名的地方，无论是`SELECT`语句、`GROUP BY`语句、`HAVING`子句，还是`ORDER BY`子句，几乎所有的地方都可以使用。

关联子查询

```sql
SELECT product_type, product_name, sale_price
FROM Product AS P1
WHERE sale_price > (SELECT AVG(sale_price) FROM Product AS P2 WHERE P1.product_type = P2.product_type) GROUP BY product_type);
```

关联子查询实际只能返回1行结果。这也是关联子查询不出错的关键。

不能把`P1.product_type = P2.product_type`放到外部，因为“内部可以看到外部，外部看不到内部”

使用视图的时候不会将数据存储到设备之中，而且也不会将数据保存到其他任何地方。实际上视图保存的是`SELECT`语句。我们从视图中读取数据时，视图会在内部执行该`SELECT`语句并创建出一张临时表。

视图的有点有两点

- 视图无需保存数据
- 视图的数据会随着原表的变化自动更新

创建视图

```sql
create view ProductSum (product_type, cnt_product)
as
select product_type, count(*)
from product
group by product_type
```

这样我们就在数据库中创建出了一副名为`ProductSum`（商品合计）的视图。请大家一定不要省略第二行的关键字`AS`。这里的`AS`与定义的名时使用的`AS`并不相同，如果省略就会发生错误。

```sql
select product_type, cnt_product
from ProductSum
```

视图就是保存好的`SELECT`语句。

多重视图会降低`SQL`的性能。

## 视图的限制

- 定义视图时不能使用`ORDER BY`子句

为什么呢，这是因为视图和表一样，数据行都是没有顺序的。实际上，有些`DBMS`在定义视图的语句是可以使用`ORDER BY`子句的，但这并不是通用的做法。

- 视图更新

视图归根结底还是从表派生出来的，因此，如果原表可以更新，那么视图中的数据也可以更新。反之亦然，如果视图发生了改变，而原表没有进行相应更新的话，就无法保证数据的一致性了。

视图和表需要同时进行更新，因此通过汇总得到的视图无法进行更新。

```sql
create view ProductJim (product_id, product_name, product_type, sale_price, prucehase_price, regist_date)
as 
select *
from Product
where product_type = '办公用品'
```

上面的视图既没有聚合又没有结合的`SELECT`语句，可以使用如下SQL添加数据行。

```sql
insert into ProductJim values ('0009', '印章', '办公用品', 95, 10, '2009-11-30')
```

删除视图
```sql
drop view ProductJim
```
