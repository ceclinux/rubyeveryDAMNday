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
