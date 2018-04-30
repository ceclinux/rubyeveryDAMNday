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
