`PostgreSQL`是唯一提供表继承功能的数据库。如果创建一张表（字表）时指定为继承自另一张表（父表），则建好的字表除了含有自己的字段外还会含有父表的所有字段。`PostgreSQL`会记录下这个继承关系，这样一旦父表的结构发生了变化，子表的结构也会自动跟着变化，这种父子继承的结构可以完美的适用需要数据分区的场景。当查询父表时，`PostgreSQL`会自动地把字表的记录也取出来。值得注意的是，并不是所有父表的特征都会被字表继承下来，比如主表的主键约束，唯一约束以及缩影就不会被继承。`Check`约束会被继承，但字表还可以另建自己的`check`约束。

```sql
create table logs_2011 (primary key(log_id)) inherits(logs)
create index ids_logs_2011_log_ts on logs using btree(log_ts);
alter table logs_2011 add constraint chk_y2011
check (log_ts >= '2011-1-1'::timestamptz and log_ts < '20120101'::timestamptz)
```

我们定义了一个`check`约束来限制只能录入2011年的数据。该`check`约束告诉查询规划器在查询父表时跳过条件不满足的字表。

无日志表的一大优势就是对其写入数据要远远开宇往普通表中写数据。按照我们的经验，一般要快15倍

- 如果数据库服务器奔溃，`PostgreSQL`将截断所有无日志表
- 无日志表不支持Gist索引，因此它就不适用于依赖`Gist`索引的数据类型

PostgreSQL在创建一张表时，会自动创建一个结构完全相同的复合数据类型，反之则不是这样。你可以使用一个符合数据类型来作为建表的模板

```sql
create type basic_user as (user_name varchar(50), pwd varchar(10));
create table super_users of basic_user (constraint pk_su primary key (user_name))
```

以及与数据类型来创建表时，你不能指定表字段的定义，一切以数据类型本身定义为准。然而，为复合数据类型新增或者移除字段时，`PostgreSQL`会自动修改相应的表结构。**这种机制的优点是，如果你的系统中有很多结构相同的表，而你可能会需要同时对所有表结构进行相同的修改，那么此时只需要修改此基础数据类型即可，这一点与表继承机制很相似**

```sql
alter type hasic_user add attribute phone varchar(10) cascade
```

```sql
set search_path=census,public
alter table facts add constraint fk_facks_1 foreign key (fact_type_id)
references lu_fact_types (fact_type_id)
on update cascade on delete restrict
create index fki_facts_1 on facts (fact_type_id)
```

1. 我们在`facts`表和`lu_fact_types`表之间定义了一个外键约束关系。有个这个约束以后，如果主表`lu_fact_types`不存在某`fact_type_id`的记录，那么从表`fact`中就不能插入该`fact_type_id`的记录。

2. 我们定义了一个级联规则、实现了以下功能：（1）如果主表`lu_fact_type`的`fact_type_id`字段发生了变化，那么从表`fact`中相应记录的`fact_type_id`字段会自动进行相应修改，以维持外键引用保持不变 （2）如果从表`fact`中还存在`fact_type_id`字段值的子路，那么主表`lu_fact_type`中相同`fact_type_id`字段值的记录就不允许被删除。`ON DELETE RESTRICT`是默认行为模式，也就是说这个子句不加也可以，但我们建议为了清晰起见最好还是加上。

3. `PostgreSQL`在简历主键约束和唯一性约束时，会自动为相应字段建立索引，但在建立外键约束时候却不会，这一点需要注意。你需要为外键字段手动简历索引以加快关联引用时的查询速度。

## 唯一性约束

主键字段的值是唯一的，但每张表只能定义一个主键，因此如果你需要保证别的字段值唯一，那么必须在该字段上简历唯一性约束或者说唯一索引。简历唯一性约束时会自动在后台创建一个相应的唯一索引。与主键字段类似，简历了唯一性约束的字段不允许为空，并且可以作为外键字段被别的表引用。不过请注意：建立了唯一缩影却没有唯一性约束的字段是可以输入空值的。下面的例子演示了如何建一个唯一索引

```sql
alter table logs_2011 add constraint uq unique (user_name, log_ts)
```

注意，是在`user_name, log_ts`这对tuple上的唯一性约束

# check约束

`check`约束能够对表的一个或者多个字段加上一个条件，表中每一行记录必须满足此条件。查询规划期也会利用`check`约束来优化执行速度，比如有些查询附带的条件与待查询表的`check`约束无交集，那么规划器会立即认定该查询未命中目标并返回。示例`6-2`中就有一个`check`约束，该约束可以告诉规划期不要视图查找不符合约束条件的记录。`check`约束支持基于函数和布尔表达式的条件，因此你可以发挥创意编写出一个非常复杂的约束条件来。以下`check`约束可以限制`logs`表中所有用户名必须都小写

```sql
alter table logs add constraint chk CHECK(user_name = lower(user_name))
```

传统的唯一性约束在比较算法中仅使用了“等于”运算符，即保证了指定字段的值在本表的任意两行记录都不相等，而`9.0`板中引入的排他性约束机制拓展了唯一性比较算法机制，可以使更多的运算符来进行比较运算，该类约束特别适用于解决有关时间安排的问题。`PostgreSQL`9.2版本中引入了区间数据类型，该类型特别适合使用排他性约束。

以下是一个使用排他约束的例子，假设你的办公场所所有固定数量的会议室，个项目在使用会议室前必须预定。该示例中使用了`&&`运算符来判定时间区段是否重叠，还使用了`=`运算符来判定会议室房间号是否重复

```sql
create table schedules(id serial primary key, room smallint, time_slot tstzrange);
alter table schedules add constraint ex_schedules
exclude using gist (room with =, time_slot with &&)
```


# 索引

B-树是关系型数据库中常见的通用索引类型，如果你对别的索引类型不感兴趣，那么一般使用B-树索引就可以了。有的场景下`PostgreSQL`会自动创建索引（比如创建主键约束或者唯一性约束时），那么创建出来的索引就是B-树类型的；如果你自己创建索引时未指定索引类型，那么也默认创建B-树类型的索引。主键约束和唯一性约束唯一支持的就是B-树索引

各种数据类型均有其自身特点，因此使用的索引类型不同个，会用到的比较运算符也不同。例如，对于基于区间类型的(range)的缩影来说，最常用的运算符是重叠运算符，然而该运算符对于快速本文搜索领域却毫无一一。对于中文这类表意文字来说，简历的索引基本上不会用到“不等于”运算符；而对引文折了表音文字简历索引时，子母A到Z的排序操作是不可或缺的。

基于以上特点，`PostgreSQL`把一类应用相近的运算符以及这些运算符适用的数据类型组合一起称为一个运算符类（简称`optclass`）。例如,`int4_ops`运算符类包含适用于`int4`类型的`= < > > <>`运算符。`PostgreSQL`提供了一张叫做`pg_class`的系统表，从中可以查到完整的运算符列表，其中包括了系统原生支持的类，也包含了通过扩展包机制添加的类。一种类型的缩影会适用特定的若干种运算符类。

```sql
select am.amname as index_method, opc.opcname as opclass_name, opc.opcintype::regtype as indexed_type, opc.opcdefault as is_default
from pg_am am inner join pg_opclass opc on opc.opcmethod = am.oid
where am.amname = 'btree'
order by index_method, indexed_type, opclass_name


"btree"	"bool_ops"	"boolean"	true
"btree"	"bytea_ops"	"bytea"	true
"btree"	"char_ops"	""char""	true
"btree"	"name_ops"	"name"	true
"btree"	"int8_ops"	"bigint"	true
"btree"	"int2_ops"	"smallint"	true
"btree"	"int4_ops"	"integer"	true
"btree"	"text_ops"	"text"	true
"btree"	"text_pattern_ops"	"text"	false
"btree"	"varchar_ops"	"text"	false
```

在示例种，仅查询了B-树的相关数据。请注意，每个索引都有多个运算符类，而其中仅有一个会被标记为默认运算符类。绝大多数这样做是没什么问题的，但并非绝对如此。

例如，B-树缩影默认的`text_ops`运算符类种并不支持`~~`运算符，如果建立B-树缩影选择了该运算符类，那么所有适用`LIKE`的查询都无法在`text_ops`运算符种适用索引。因此，如果你的业务场景需要对`varchar`或者`text`类型进行大量`LIKE`模糊查询，那么建缩影时最好是显式适用`text_pattern_ops`或者`varchar_pattern_ops`这两个运算符类。指定运算符类的语法很简单，只需要在建缩影时候加载被索引字段名的后面即可

```sql
create index idx1 on census.lu_tracts using btree (tract_name text_pattern_ops)
```

最后请牢记一条，你创建的每一个缩影都只会适用一个运算符类。如果希望一个字段上的索引适用多个运算符类，那么请创建多个索引

```sql
create index idx2 on census.lu_tracts using btree (tract_name);
```

现在，在同一个字段上就有了多个索引（单个字段上可建立索引的个数是没有限制的）。规划器处理等值查询时会适用`idx2`，处理`like`查询时会适用`idx1`。 

`PostgreSQL`的函数功能可以基于字段值的函数运算结果建立索引。函数缩影的用途也是很广泛的，例如可用于对大小写混杂的文本数据建立索引。`PostgreSQL`是一个区分大小写的数据库，如果要实现不区分大小写的查询，那么可以借助如下的函数索引

```sql
create index fidx on featnames_short
using btree (upper(fullname) varchar_pattern_ops)
```

建立了索引之后，类似`SELECT fullname FROM featnames_short WHERE upper(fullname) LIKE 'S%'`这种类型就可以用上索引了。不过要注意，查询语句种使用的函数要与建函数缩影时使用的函数完全一致，这样才能保证用上索引。

## 基于部分记录的索引

基于部分记录的索引（有时也称为已筛选索引）是一种针对表中部分记录的索引，而且这部分记录需要满足`WHERE`语句设置的筛选条件。例如，假设某表中共有`1000000000`条记录，但你值会查询其中一个记录数为`10000`的子集，那么该场景就非常适合使用基于部分记录的索引。这种缩影比全量索引要快，因为其体积小，所以可以把更多缩影数据缓存到内存中，另外该类缩影占用的磁盘空间也会更小。

```sql
create table subscribes (id serial primary key, name varchar(50) not null, tyoe varchar(50), is_active boolean)
```

```sql
create unique index uq on subscribes using btree(lower(name)) where is_active;
```

多列索引也称为复合索引。另外我们还想介绍的一点是：你可以使用多个基础列创建功能索引。以下是一个多列索引的示例。

```sql
CREATE INDEX idx on subscribes USING btree (upper(name) varchar_pattern_ops)
```

`PostgreSQL`的规划器在语句执行过程中会自动个实用一种被称为“位图索引扫描”的策略来同时使用多个索引。该策略可以使多个单列索引同时发挥作用，达到的效果与使用单个复合索引相同。如果你不能确定业务的应用模式是以单列作为查询条件的场景多一些还是同时以多列作为查询条件的场景多一些，那么最好针对可能作为查询条件的每个列单独建立索引，这样是最灵活的做法，规划器会决定如何组合使用这些索引

假设你见了一个复合`B-`树索引，其中半酣`type`、`upper(name)`等多个字段，那么完全没必要针对`type`字段再单独建一个索引，因为规划器要针对`type`字段再单独建一个索引，因为规划器即使在遇到只有`type`但字段的查询条件时也会自动使用该复合索引，这是规划器的一项基本能力。

索引中包含的字段越多也就意味着索引占用的空间越大，能在内存中缓存的索引条目就越少，因此请不要滥用符合索引
