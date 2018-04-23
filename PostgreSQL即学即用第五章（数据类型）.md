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

`string_agg`: 	input values concatenated into a string, separated by delimiter

重叠运算符`&&`的作用就是判定两个区间是否有重叠部分，如果有则返回`true`，否则返回`false`。
```sql
select e1.employee, string_agg(distinct e2.employee, ', ' order by e2.employee) as colleagues
from employment as e1 inner join employment as e2
on e1.period && e2.period
where e1.employee <> e2.employee
group by e1.employee

|employee|colleagues|
|Alex|Leo, Regiona, Sonia|
|Leo|Alex, Regiona|
|Regiona|Alex, Leo|
|Sonia|Alex|
```

对于包含关系运算符`@>`来说，第一个实参是区间

```sql
select employee from employment where period @> CURRENT_DATE GROUP BY employee

|employee|
|alex|
```

```sql
insert into families_j (profile) values (
	'{"name": "Gomez", "members": [
	{"member": {"relation": "padre", "name": "Alex"}},
	{"member": {"relation": "madre", "name": "Sonia"}},
	{"member": {"relation": "hijo", "name": "Brandom"}},
	{"member": {"relation": "hija", "name": "Azaleah"}},]}'
)
```

```sql
select json_extract_path_text(profile, 'name') as family, json_extract_path_text(json_array_elements(json_extract_path(profile, 'members')), 'member', 'name') as member
from families_j

|family text|memeber text|
|Gomez|Alex|
|Gomez|Sonia|
|Gomez|Brandom|
|Gomez|Azaleah|
```

`postgresql`的数组下标是从1开始

```sql
select row_to_json(f) as x
from (select id, profile ->> 'name' as name from families_j) as f

{
    "id": 1,
    "name": "Gomez"
}
```

如果要将`families`表中的所有记录行整理打包一个`JSON`

```sql
select row_to_json(f) from families_j as f
```

`jsonb`与`json`数据类型的区别如下所示

1. `json`是以原始文本储存的，而`jsonb`存储的是原始文本解析以后生成的二进制数据结构，该二进制结构中不再保存原始文本中的空格，存储下来的数字的形式也发生一定的变化，并且对其内部记录属性值进行了排序。

2. `jsonb`不允许其内部记录的值重复，如果出现重复则自动选择一条，其余的重复记录会被丢弃。但`json`类型中记录键值重复是允许的。

3. `jsonb`的性能远好于`json`。因为`jsonb`类型在处理过程中不需要再进行文本解析。

```sql
create table families_b (id serial primary key, profile jsonb)
```

```sql

select profile as j from families_j where id = 1

|j|
{
    "name": "Gomez",
    "members": [
        {
            "member": {
                "relation": "padre",
                "name": "Alex"
            }
        },
        {
            "member": {
                "relation": "madre",
                "name": "Sonia"
            }
        },
        {
            "member": {
                "relation": "hijo",
                "name": "Brandom"
            }
        },
        {
            "member": {
                "relation": "hija",
                "name": "Azaleah"
            }
        }
    ]
}
```


1. 可以看出，`jsonb`类型的输出是对输入的内容进行了重新格式化并删掉了输入时文本中的空格，此外`relation`和`name`这两个属性字段的显示顺序与输入时的顺序下相比发生了翻转。

2. json类型的输出保持了输入时的原样，包括原文中的空格以及属性字段的顺序。

jsonb与json的处理函数一一对应，但函数名略有不同；`jsonb`支持的运算符集合是`json`支持的运算符集合的超集。

在往一个`xml`类型的列中插入数据时，`Postgresql`会自动判定并确保只有格式合法的`XML`才会创建成功。`text`类型中也可以存入一段`XML`文本，但是存入时不会进行格式合法性判断，这一点是`text`与`xml`类型的区别。不过请注意，即使`XML`文本的内容中附带了`DTD`或者`XSD`的格式描述，`PostgreSQL`也不会按照这些格式要求来对`XML`格式进行验证。

```sql
insert into families(profile)
values('<family name="Gomez">
	  <member><relation>padre</relation><name>Alex</name></member>
	  <member><relation>madre</relation><name>Sonia</name></member>
	   <member><relation>hijo</relation><name>Brandom</name></member>
	   <member><relation>hija</relation><name>Azaleah</name></member>
	   </family>'
	  )
```

```sql
alter table families add constraint chk_has_relation
check (xpath_exists('/family/member/relation', profile))
```

该约束要求输入的`XML`数据中的`family`节点下都有一个`relation`节点。'/family/member/relation'是Xpath语法，Xpath是一种能够在`xml`树状结构中定位到指定元素的语法。

如果插入

```sql
insert into families (profile) values ('<family name="HsuObe"></family>');
```

会看到报错信息。

```sql
select family, (xpath('/member/relation/text()', f))[1]::text as relation,
(xpath('/member/name/text()', f))[1]::text as mem_name
from (select (xpath('/family/@name', profile))[1]::text as family, unnest(xpath('/family/member', profile)) as f from families) x;

"Gomez"	"padre"	"Alex"
"Gomez"	"madre"	"Sonia"
"Gomez"	"hijo"	"Brandom"
"Gomez"	"hija"	"Azaleah"
```

1. 获取`memeber`元素的`relation`标签和`name`标签中包含的文本元素。此处的语法中必须加数组下标，以为`xpath`语法返回的查询结果是数组类型的，即使返回的数组中只有一个元素也得加下标才能访问。

2. 访问`family`根节点的`name`属性值。访问属性值的语法为`@attribute_name`。

```sql
create table chickens (id integer primary key);
create table ducks (id integer primary key, chickens chickens[]);
create table turkeys (id integer primary key, ducks ducks[]);

insert into ducks values (1, array[row(1)::chickens, row(1)::chickens]);
insert into turkeys values (1, array(select d from ducks d));
```

上面我们直接在`ducks`表的一条记录的`chickens`字段中插入了两条`chickens`记录，这种情况下这两条记录的构造不受`chickens`表定义的约束，因此即使它们的主键重复也没关系。我们生成了两条`chickens`记录，填入`ducks`表中，然后将这条`ducks`记录填入到`turkeys`表中，这个郭晨个相当于把两只`chicken`塞入一只`duck`，然后再把`duck`塞入一只`turkey`，跟制作特大啃的过程是完全一样的。


```sql
select * from turkeys

|id|ducks|
|1|"{"(1,\"{(1),(1)}\")"}"|
```

```sql
update turkeys set ducks[1].chickens[2] = row(3)::chickens
where id = 1 returning *

|id|ducks|
|1|"{"(1,\"{(1),(3)}\")"}"|
```

```sql
create type complex_number
as (r double precision, i double precision)
```

```sql
create table circuits (circuit_id serial primary key, ac_volt complex_number)
```

可以使用如下语法对这个表进行查询

```sql
select circuit_id, (ac_volt).* from circuits
```

在`pg`中，你可以对函数和运算符进行重载，使其可以接受多种不同类型的输入。例如，你可以创建一个支持`complex_number`和`integer`相加的`add`函数和相应的`+`计算符，这就实现了对原逻辑的扩展。
