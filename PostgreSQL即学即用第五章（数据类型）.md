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
