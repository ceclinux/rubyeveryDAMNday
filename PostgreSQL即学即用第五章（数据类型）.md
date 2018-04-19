`serial`类型和它的兄弟类型`bigserial`是两种可以自动生成递增数值的数据类型，一般如果表本省的字段不适宜作为主键字段时，会增加一个专门的字段并指定为`serial`类型作为主键。在不同的数据库产品中着不同的称呼，一般最常见的是`autonumber`。建表时如果指定了一个字段类型为`serial`那么`PostgreSQL`会首先先将其作为整型处理，同时自动在该表中创建一个名为`table_name_column_name_seq`的序列。

```sql
create table testseq(id serial,name varchar(100));
```

```sql
SELECT nextval('testseq_id_seq'); 
```

```sql
select x from generate_series(1,51,13) as x
```

`PosgtreSQL`有三种最基础的数据类型：`character`（也称为`char`）、`character varying`（也称为`varchar`）和`text`。这两种类型的存储方式是完全一致的，性能表现也没有差别。

```sql
select lpad('ab', 4, '0') as ab_lpad, rpad('ab', 4, '0') as ab_rpad, lpad('abcde', 4, '0') as ab_lpad_trunc

|ab_lpad|ab_rpad|ab|lpad_trunc|
|00ab|ab00|abcd|
```

```sql
select split_part('abc.123.z45', '.', 2) as x;

|x|
|123|
```

```sql
select unnest(string_to_array('abc.123.z45', '.')) as x;

|x|
|abc|
|123|
|z45|
```

```sql
select regexp_replace('6197306254', 
					'([0-9]{3})([0-9]{3})([0-9]{4})',
					E'\(\\1\) \\2-\\3'
					) as x;

|x|
|(619) 730-6254|
```

如果你自定义了一个数据类型，那么`PostgreSQL`会在后台自动为此创建一个数组类型。例如，`integer`整数类型有一个相应的装束数组类型`integer[]`，字符类型`character`有一也有相应的字符数组类型`character[]`，以此类推。

```sql
select array[2001, 2002,2003] as year;

|year|
|"{2001,2002,2003}"|
```

你可以把一个直接以字符串格式书写的数组转换成一个真正的数组
```sql
select '{Alex, Sonia}'::text[] as name, '{43, 40}'::smallint[] as age

|name|age|
|{alex, Snia}|{43,40}|
```

```sql
select string_to_array('ca.ma.tx', '.') as estados

|estados|
|{ca,ma,tx}|
```

```sql
select (ARRAY[2001, 2002, 2003])[1] as yrs

|yrs|
|2001|
```

```sql
select (ARRAY[2001, 2002, 2003])[1] || ARRAY[2] as yrs

|yrs|
|"{2001,2}"|
```

```sql
select unnest('{XOX, OXO, XOX}'::char(3)[]) as tic_tac_toe

|tic_tac_toe|
|XOX|
|OXO|
|XOX|
```

PostgreSQL对离散区别和连续区间是区别对待的。整数类型或者日期类型的区间是离散区间，因为区间的每一个值都是可以被枚举出来的。数字全歼或者时间戳区间是一个连续区间，因为区间内的值无限多。

```sql
select '[2013-01-05, 2018-08-13]'::daterange;
select '([2013-01-05, 2018-08-13]'::daterange;
-- 大于0小于等于正无穷的区间
select '(0,)'::int8range;
select '(2013-01-05 10:00, 2013-08-13 14:00)'::tsrange;
```

你可以定义一个员工的服务年限，而不需要用起始时间和结束时间两个字段表示
```sql
create table employment (id serial primary key, employee varchar(20), period daterange);
insert into employment (employee, period) values ('Alex', '[2012-04-24, infinity)'::daterange)
```
