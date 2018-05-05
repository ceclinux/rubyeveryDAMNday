```sql
create or replace view vm_facts_2011 as select purchase_price from product where purchase_price < 500
```

你可以插入和跟新将该视图的置于`WHERE`条件之外的数据

```sql
update vm_facts_2011 set purchase_price = 500
```

```sql
select * from vm_facts_2011
```

的结果为空

但为了保持视图数据的一致性，我们不希望这种情况发生，也就是希望跟新后的数据依然应该落在视图的可见范围内。这可以通过`9.4`版本的`WITH CHECK OPTION`修饰符来实现。创建视图如果包含此修饰符，那么此视图插入的数据或者更新后的数据落在视图可见范围之外时，系统会报错，违反了该约束的操作会失败。

如果视图的基表有多张，那么直接更新该视图是不允许的。因为多张表必然带来的问题就是操作要落到哪个击败哦上，`PostgreSQl`是无法自动判定的。假设你有一个视图，该视图基于一张国家信息表和一张省份信息表，此是你希望删除该视图上的一个记录，`PostgreSQL`无法得知你到底想要仅删除一个国家记录，还是仅删除一个省份记录，韩式从删除一个国家以及该国家对应的所有省的记录。`PostgreSQL`无法判定你想做什么并不代表就不能对这种复杂视图进行修改操作，你可以通过编写出发器对这些操作进行转移处理，转移后的逻辑中可以体现你的意图。


在`vm_facts`视图上建一个对`insert,update,delete`操作进行转义处理的函数

```sql

CREATE OR REPLACE FUNCTION census.trig_vm_facts_ins_upd_del() returns trigger AS
$$
BEGIN
IF (TG_OP = 'DELETE') THEN
DELTE FROM census.facts AS f
WHERE
f.tract_id = PLD.tract_id AND f.yr = OLD.yr AND
f.fact_type_id = PLD.fact_type_id;
RETURN OLD;
END IF;
$$ 
```

OLD记录是指原始的针对视图的删除动作所要删除的视图记录。也就是说，`OLD`记录是视图记录，而非视图基础表的记录。

物化视图会把视图可见范围内的数据在本地缓存下来，然后就可以当作一张本地表来使用。首次创建无话视图以及对其执行`REFRESH MATERIALIZED VIEW`刷新操作都会出发数据缓存动作，至不错牵着是全量缓存，后者是增量刷新。

无话视图最典型的应用场景是用于加速时效性要求不高的长时复杂查询。

物化视图还有一个特点就是支持简历索引以加快查询速度。

```sql
create materialized view product_view as select sale_price, purchase_price from product
```

```sql
create unique index ix on product_view (sale_price)
```

当物化视图中含大量记录时，为了加快对它的访问速度，我们需要对数据进行排序。要实现这一点，最简单的方法就是在创建物化视图时使用的`SELECT`语句中增加`ORDER BY`子句。另外一种放假啊就是对其执行聚簇排序操作以是的记录的物理存储顺序与索引的顺序相同。具体步骤是：首相创建一个索引。该索引应体现你所希望的排序，然后基于指定索引对物化视图执行`CLUSTER`命令

> Materialized views are disk based and are updated periodically based upon the query definition.

> Views are virtual only and run the query definition each time they are accessed.

物化视图每次刷新数据时都要执行一次`REFRESH MATERIALIZED VIEW`操作。`PostgreSQL`不支持自动刷新物化视图。要实现自动刷新，你必须使用`crontab`、`pgagent`定时任务或者是触发器这张的机制。

```sql
create table a6(id integer, name varchar(10));
insert into a6 values(1, ' 001');
insert into a6 values(1, '002');
insert into a6 values(2, '003');
insert into a6 values(2, '004');
```

```sql
select distinct on (id) id, name from a6;

id | name
---+--------
1 | 001
2 | 003
(2 rows)
```


## 简化的类型转换语法
```sql
select cast('2011-1-11' as date)
```

等同于

```sql
select '2011-1-11'::date
```

`PostgreSQL`中的`VALUES`子句并不是只能作为`INSERT`语句的一部分来使用，他其实是一个动态生成的临时结果集。

```sql
select *
from (values (2, 'logged in', '2011-01-10 10:15 AM EST'::timestamptz), (5,'logged out','2011-01-10 10:25 AM EST'::timestamptz)
	 ) as l (user_name, description,log_ts)
```

将`VALUES`子句当作一个虚拟表来用时，需要为该表指定字段名，并将那些无法隐式转换的字段值显式的进行类型转换。

`ILIKE`不去分大小写的查询

```sql
select *
from (values ('haha'),('Ha')) as l (name) where name ilike 'ha%'
```

```sql
create table interval_periods (i_type interval);
insert into interval_periods (i_type)
values ('5 months'),('123 days'),('4862 hours');

select i_type, generate_series('2012-01-01'::date, '2012-12-31'::date, i_type) as dt from interval_periods

"5 mons"	"2012-01-01 00:00:00+00"
"5 mons"	"2012-06-01 00:00:00+00"
"5 mons"	"2012-11-01 00:00:00+00"
"123 days"	"2012-01-01 00:00:00+00"
"123 days"	"2012-05-03 00:00:00+00"
"123 days"	"2012-09-03 00:00:00+00"
"4862:00:00"	"2012-01-01 00:00:00+00"
"4862:00:00"	"2012-07-21 14:00:00+00"
```

在一个复杂的`SQL`语句中使用返回结果集的函数很容易导致意外的结果，这是因为这类函数输出的结果集会与该语句其他部分生成的结果集产生笛卡儿积，从而生成更多的数据行。

PostgreSQL lets you reference columns of other tables in the WHERE condition by specifying the other tables in the USING clause. For example, to delete all films produced by a given producer, one can do:

```sql
DELETE FROM films USING producers
  WHERE producer_id = producers.id AND producers.name = 'foo';
```

```sql
In an UPDATE, the data available to RETURNING is the new content of the modified row. For example:

UPDATE products SET price = price * 1.10
  WHERE price <= 99.99
  RETURNING name, price AS new_price;

In a DELETE, the data available to RETURNING is the content of the deleted row. For example:

DELETE FROM products
  WHERE obsoletion_date = 'today'
  RETURNING *;
```

```sql
SELECT array_to_json(array_agg(f)) as cat -- 1
from (
    select max(fact_type_id) as max_type, category
    from census.lu_fact_types
    group by category
) as f -- 将子查询中f中的所有记录转换为一个基于复合数据类型的数组
```

PostgreSQL提供了一个名为`json_agg`的函数，该函数的效果相当于上面示例中`array_to_json`和`array_agg`联用的效果，但`json_agg`执行速度更快。

```sql
SELECT json_agg(f)  == SELECT array_to_json(array_agg(f)) as cat -- 1
```

9.4版本使用了`FILTER`子句，这是近期`ANSI SQL`标准中新加入的一个关键字。该关键字用于替代为`ANSI SQL`标准语法的`CASE WHEN`语句，使聚合操作的语法得以简化。例如，假设你需要使用`CASE WHEN`子句来统计每个学生不同科目的多次测试的平均成绩

```sql
SELECT students,
AVG(CASE WHEN subject= 'algebra' then score ELSE NULL END) As algebra
FROM test_score
GROUP BY student
```

用`FILTER`子句可以实现与上面语句等价的结果

```sql
AVG(score) FILTER (WHERE subject = 'algebra') As algebra
```

`PostgreSQL`从`8.4`版开始支持`ANSI SQL`标准中规定的窗口函数特性。通过使用窗口函数，可以在当前记录行中访问到预期存在特定关系的其他记录行，相当于在每行记录上都开了一个访问外部数据的窗口，这也是“窗口函数”这个名称的由来。“窗口”就是当前行可见的外部记录行的范围。通过窗口函数可以把当前行的“窗口”区域内的记录的聚合运算结果附加到当前记录行

```sql
select avg(purchase_price) over ()
from product
```

`OVER`子句先顶了窗口中可见记录范围。本例中的`OVER`子句未设定任何条件，因此从该窗口中能看见全表所有记录。

窗口函数的窗口可见记录是可设置的，可以是全表记录，也可以是与当前行有关联关系的特定记录行。在这里，是以`prouduct_type`的前两个字符作为窗口筛选条件

```sql
select product_name, product_type, avg(purchase_price) over (partition by left(product_type, 2))
from product
```

```sql
select tract_id, val,
sum(val) over (partition by left(tract_id, 5)) order by val) as sum_county_ordered
from census.facts
where fact_type_id = 2
order by left(trace_id, 5), val

tract_id|val|sum_county_ordered
25001014100|226|226
25001014100|971|1197
25001014100|984|2181
...
...
25003933200|564|564
25003934200|593|1157
25003931300|606|1763
```

可以看到上面输出的合计值是逐行累加的，这就是在`OVER`子句中应用了`ORDER BY`后的效果，即窗口可见域是从排序后的记录集的头条记录开始的，到`ORDER BY`字段值与当前记录纸匹配的那行记录为止，因此最终会呈现动态累加的结果。例如，对于第三个数据分区中的第五条记录来说，合计值仅会包含该分区的前五条记录的值。

`OVER`语句的`ORDER BY`与证据尾部的`ORDER BY`的作用是完全不同的。

`lead` returns value evaluated at the row that is offset rows after the current row within the partition;
`lag`returns value evaluated at the row that is offset rows before the current row within the partition

`PostgreSQL`还支持建立命名窗口，该功能适用于在一个查询中使用了多个窗口函数且每个窗口函数的窗口定义都相同的情况。

```sql
select ROW_NUMBER() over (wt) as rnum
from product WINDOW wt as (partition by product_id)
```

`lead`和`lag`在寻找目标巨鹿的过程中跳出了当前窗口的可见域时，就会返回`null`。

共用表表达式`CTE`本质就是在一个非常庞大的`SQL`语句中允许用户通过一个子查询先定义出一个临时表，然后在这个庞大的`SQL`语句的不同地方都可以直接使用这个临时表。`CTE`本质就是当前语句执行期间内有效的临时表，一旦当前语句执行完毕，其内部的`CTE`表也随之失效。

1. **基本CTE**这是最普通的`CTE`，它可以使得`SQL`语句的可读性更搞，同时规划期在解析到这种`CTE`是时会判定其查询代价是否很高，如果是的话，会考虑将其查询结果零食物化储存下来（此处概念跟物化视图非常相似），这样整个`SQL`语句的其他部分再访问此`CTE`时会更快

2. **可写CTE**这是对基本`CTE`的一个功能扩展。其内部可以执行`UPDATE`、`INSERT`或者`DELETE`操作，该类`CTE`最后一般会返回修改后的记录集。

3. **递归CTE**该类CTE在普通`CTE`的基础上增加了一个循环操作。在执行过程中，递归`CTE`返回的结果集会有所变化。

```sql
with cte as (
select
	product_id
	from product
)

select product_id
from product
```

外围的`SQL`语句会将该`CTE`作为一个临时表来使用

单个`SQL`语句可以创建多个`CTE`，`CTE`之间使用逗号分割，所有的`CTE`表达式都要落在`WITH`子句的范围。
