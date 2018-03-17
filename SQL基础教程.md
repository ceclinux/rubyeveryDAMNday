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
