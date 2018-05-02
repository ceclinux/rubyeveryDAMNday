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
