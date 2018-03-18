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

主键是可以唯一确定一行数据的列。

```sql
ALTER TABLE Product ADD COLUMN product_name_pinyin VARCHAR(100)
```

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
