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

# 索引

B-树是关系型数据库中常见的通用索引类型，如果你对别的索引类型不感兴趣，那么一般使用B-树索引就可以了。有的场景下`PostgreSQL`会自动创建索引（比如创建主键约束或者唯一性约束时），那么创建出来的索引就是B-树类型的；如果你自己创建索引时未指定索引类型，那么也默认创建B-树类型的索引。主键约束和唯一性约束唯一支持的就是B-树索引
