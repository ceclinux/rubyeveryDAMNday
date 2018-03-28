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

```sql
insert into ProductIns (product_id, product_name, product_type, sale_price, purchase_price, regist_date) values
('0001','T恤衫', '衣服', 1000, 500, '2009-09-20');
```

将列名和值用逗号分开，风别括在（）内，这种形式称为**清单**。以上代码包含如下两个清单

```sql
(product_id, product_name, product_type, sale_price, purchase_price, regist_date)
```

```sql
('0001','T恤衫', '衣服', 1000, 500, '2009-09-20')
```

对表进行全列`INSERT`时，可以省略表名后的列清单。这时`VALUES`子句的值会默认按照从左到右的顺序付给每一列。

```sql
INSERT INTO ProductIns VALUES ('0005', '高压锅', '厨房用具',6800,5000, '2009-01-15')
```

```sql
INSERT INTO ProductIns (product_id, product_name, product_type, sale_price, purchase_price, regist_date) values
('0007', '擦菜板', '厨房用具', DEFAULT,790, '2009-04-28')
``` 

插入默认值时也可以不使用`DEFAULT`关键字，只要在列清单和`VALUES`中省略设定了默认值的列就好了，我们可以省略`sale_price`列

如果省略了没有默认值的列，该列的值就会被设定为`NULL`。因此，如果省略的是设置了`NOT NULL`的列，`INSERT`语句就会出错。


## insert...select语句
```sql
insert into ProductCopy (product_id, prodcut_name, product_type, sale_price, purchase_price, regist_date)
select product_id, product_name, product_type, sale_price, purchase_price, regist_date
from Product
```

`DELETE`语句删除的对象并不是表或者列，而是记录。

```sql
DELETE FROM Product
where sale_price >= 4000;
```

与`DELETE`不同的是，`TRUNCATE`只能删除表中的所有数据，而不能通过`WHERE`来执行条件删除部分数据。所以要比`DELETE`快的多。

```sql
update Product
set regist_date = '2009-10-10'
```

将厨房用具的销售单价提高十倍
```sql
update Product
set sale_price = sale_price * 10
where product_type = '厨房用具'
```

多列更新
```sql
update Product
set sale_price = sale_price * 10,
purchase_price = purchase_price / 2
where product_type = '厨房用具'
```

可以使用`||`对字符串进行拼接（`pg上`），比如说`str || str2 || str3`

谓词就是转换值为真值的函数。

以`ddd`开头的所有字符串
```sql
select *
from SampleLike
where strcol like 'ddd%'
```

```sql
select product_name, sale_price
from Product
where sale_price between 100 and 1000;
```

`BETWEEN`的特点是结果中会包含`100`和`1000`这两个临界值。

为了选取某些值为`NULL`的列的数据，不能使用`=`，而只能使用特定的谓词`IS NULL`。

```sql
select product_name, purchase_price
from Product
where purchase_price is NULL;
```

同样，想要选取`NULL`以外的数据时，需要使用`IS NOT NULL`。

`IN`谓词，`OR`的简便用法

```sql
select product_name, purchase_price
from Product
where purchase_price in (320, 500, 5000)
```

但需要注意的是，在使用`IN`和`NOT IN`时是无法选取出`NULL`数据的。

`IN`谓词（`NOT IN`谓词）具有其他谓词没有的用法，那就是可以使用子查询作为参数。我们可以说，能够将视图作为`IN`的参数。

```sql
select product_name, sale_price
from Product
where product_id in (select product_id from ShopProduct where shop_id = '000C')
```

```sql
select *
from Product as P
where exists (select * from ShopProduct as SP where SP.shop_id = '000C' and SP.product_id = P.product_id)
```

由于`EXIST`只关心列记录是否存在，因此返回那些列都没关系。

`CASE`表达式是在区分情况时使用的，这种情况的区分在编程中通常称为`(条件)分支`。

```sql
select product_name,
case when product_type = '衣服'
then 'A: ' || product_type
when product_type = '办公用品'
then 'B: ' || product_type
when product_type = '厨房用具'
then 'C: ' || product_type
else null
end as abc_product_type
from Product;
```

`ELSE`子句也可以省略不写，这时会被默认为`ELSE NULL`。

```sql
select sum(case when product_type = '衣服' then sale_price else 0 end) as sum_price_clothes,
sum(case when product_type = '厨房用具' 
	then sale_price else 0 end) as sum_price_kitchen,
sum(case when product_type = '办公用品'
	then sale_price else 0 end) as sum_price_office
from Product
```

`NOT IN`的参数中包含`NULL`时结果通常为空，也就是无法选取出任何记录。

```sql
select sum(case when product_type = '衣服' then sale_price else 0 end) as sum_price_clothes,
sum(case when product_type = '厨房用具' 
	then sale_price else 0 end) as sum_price_kitchen,
sum(case when product_type = '办公用品'
	then sale_price else 0 end) as sum_price_office
from Product
```

```sql
select product_id, product_name
from product

union
select product_id, product_name
from Product2
```

`UNION`集合运算符会删去重复的事务

## 集合运算的注意事项

1. 作为运算对象的记录的列数必须相同
2. 作为运算对象的记录中的列的类型必须一致
3. 可以使用任何`SELECT`语句，但`ORDER BY`子句只能在最后使用一次

```sql
select product_id, product_name
from Product
where product_type = '厨房用具'
union
select product_id, product_name
from Product2
where product_type = '厨房用具'
order by product_id
```

只需在`UNION`之外的集合添加`ALL`关键字，就可以保留重复行。

```sql
select SP.shop_id, SP.shop_name, SP.product_id, P.product_name, P.sale_price
from ShopProduct as SP INNER JOIN Product AS P
ON SP.product_id = P.product_id
```

内联结要点（`ON`子句）
```sql
ON SP.product_id = P.product_id
```

进行内联结的时候必须使用`ON`子句，并且要书写在`FROM`和`WHERE`之间。

对于外联结来说，只要数据存在于某一张表中，就能够读取出来。

外联结还有一点非常重要，那就是要把哪张表作为主表。最终的结果中会包含主表内所有的数据。指定主表的关键字是`LEFT`或`RIGHT`。

```sql
select SP.shop_id, SP.shop_name, SP.product_id, P.product_name, P.sale_price, IP.inventory_quantity
from ShopProduct AS SP INNER JOIN Product as P
on SP.product_id = P.Product_id
INNER JOIN InventoryProduct as IP
ON SP.product_id = IP.product_id
WHERE IP.inventory_id = 'P001'
```

## CROSS JOIN

```sql
select SP.shop_id, SP.shop_name, SP.product_id, P.product_name
FROM ShopProduct AS SP CROSS JOIN Product AS P;
```

因为`ShopProduct`表存在`13`条记录，`Product`表存在`8`条记录，所以结果中出现了`8 * 13 = 104`条记录。


除法运算是存在的。集合运算中的除法通常称为关系出。关系是数学领域中对标或者视图的陈伟，但是没有定义像`UNION`或者`EXCEPT`这样的运算符。

```sql
select distinct emp
from EmpSkills ES1
where not exists
(select skill from Skills
except
select skill
from EmpSkills ES2
where ES1.emp = ES2.emp) 
```

窗口函数也称为`OLAP`函数。为了让大家快速形成直观印象，才起了这样一个容易理解的名称。

`OLAP`是`Online Analytical Processing`的简称，意思是对数据库进行实时分析处理。例如，市场分析、创建财务报表、创建计划等日常性上午工作。

窗口函数就是为了实现`OLAP`而添加的标准`SQL`功能。

```sql
select product_name, product_type, sale_price,
rank() over (partition by product_type order by sale_price) as ranking
from Product
```

`PARTITION BY`能够设定排序的对象范围，本例中个，为了按照商品种类进行排序，我们指定了`product_type`。

`ORDER BY`能够指定哪一列、何种顺序进行排序。为了按照销售单价的升序进行排列，我们指定了`sale_price`。此外，窗口函数中的`ORDER BY`与`SELECT`函数语句末尾的`ORDER BY`一样，可以通过关键字`ASC/DESC`来指定升序和降序。

窗口函数兼具分组和排序两种功能。

通过`PARTITION BY`分组后的记录集合称为“窗口”。

上述如果不用`PARTITION BY`会对所有进行排序。

窗口函数只能在`SELECT`中使用。

所有的聚合函数都能用作窗口函数，其语法和专用窗口函数完全相同。

```sql
select product_name, product_type, sale_price,
sum(sale_price) over (order by product_id) as current_sum
from Product
```

计算合计值的逻辑就像金字塔堆积那样，一行一行逐渐添加计算对象。

窗口函数就是将表以窗口为单位进行分割，并在其中进行排序的函数。其实其中还包含在窗口中指定更加详细的汇总返回的备选功能，该备选功能中的汇总范围称为框架。

```sql
select product_name, product_type, sale_price,
avg(sale_price) over (order by product_id rows 2 preceding) as moving_avg
from Product
```

这里我们使用了`ROWS`和`PRECEDING`两个关键字，将框架指定为“截止到之前~行”。因此“`ROWS 2 PRECEDING`”就是将框架指定为“截止到之前两行”，也就是将汇总对象的记录限定为如下的“最靠近的3行”。

这样的统计方法为移动平均。由于这种方法在希望实时把握“最近状态”时非常方便，因此常常会应用在对故事趋势的实时追踪当中。

当前记录的前后行

```sql
select product_name, product_type, sale_price,
avg(sale_price) over (order by product_id rows between 1 preceding and 1 following) as moving_avg
from Product
```

`OVER`子句中的`ORDER BY`只是用来决定窗口函数按照什么样的顺序进行计算的，对结果的排列顺序并没有影响。

```sql
select product_name, product_type, sale_price,
rank() over (order by sale_price) as ranking
from Product
order by ranking desc
```

`GROUPING`运算符包含以下三种

- `ROLLUP`
- `CUBE`
- `GROUPING SETS`

```sql
select product_type, SUM(sale_price) as sum_price
from Product
group by ROLLUP(product_type)
```

`ROLLUP`可以得出合计和小计。

为了避免混淆，`SQL`提供了一个用来判断超级分组记录的`NULL`的特定函数，`GROUPING`函数。该函数在其参数列的只为超级分组记录所产生的`NULL`的值时返回1，其他情况返回0。

```sql
select grouping(product_type) as product_type,grouping(regist_date) as regist_date, SUM(sale_price) as sum_price
from Product
group by ROLLUP(product_type, regist_date)
```

所谓`CUBE`，就是将`GROUP BY`子句中聚合键的“所有可能组合”的汇总结果集中到一个结果中。因此，组合的个数就是`2^n`。本列中的组合键有`2`个，所有组合个数就是4。

之前的`CUBE`的结果就是根据聚合键的所有可能的组合计算而来的。如果希望从中选取出将“商品种类”和“登记日期”各自作为聚合键的结果，或者不想的得到“合计记录和使用2个聚合键的记录”时，可以使用`GROUPING SETS`。
