```sql
`EXPLAIN ANALYSE`的执行结果
```
```sql
Seq Scan on hisp_pop
  (cost=0.00..33.48 rows=1 width=16)
  (actual time=0.205..0.339 rows=1 loops=1)
  Filter: ((tract_id)::text='2502010103'::text)
  Rows Removed by Filter:1477
Total runtime:0.360
```
集合所有的执行计划都会包含多个步骤，每一步骤又可以包含若干个子步骤。每一步骤会有一个估算的执行时间范围，看起来像这样：`cost=0.00..33.48`，如示例`9-2`所示。其中第一个数字`0.00`是估算的该步骤起始执行时间，第二个数字`33.84`是估算的该步骤总执行时间。起始执行时间点之前会执行一些后续计算的准备工作，而读取数据、索引扫描、夺表数据关联整合等动作都是在其实执行时间点之后发生的。如果执行方式未全表扫描，那么其其实执行时间点为0，因为这种场景下只是简单地立即开始扫描全表数据，没有什么预备动作。

请注意，估算的执行时间（cost）的单位并不是真实的时间单位，而是取决于硬件环境以及规划器的执行时间单位常数。因此，`cost`值金鱼有相对意义，**可用于比较同一台物理服务器上多个执行计划之间的效率**。规划器的任务就是要选择出整体`cost`最低的一个执行计划。

通过示例`9-2`中的执行计划可以看到规划器选择了全表扫描策略，因为没有任何索引可用。小输出的`Rows Removed by Filter:1477`是扫描过程中排除掉的不符合条件的记录数。

在`PostgreSQL 9.4`版本中，`EXPLAIN`输出的执行计划中区分了分析执行计划的时间和真正的执行时间，并将两者分开单列。

```sql
Planning time: 0.095ms
Execution time: 0.381ms
```

我们将主键重新建立起来

```sql
ALTER TABLE census.hisp_pop ADD CONSTRAINT hisp_pop_pkey PRIMARY KEY(tract_id)
```

```sql
Index Scan using idx_hisp_pop_tract_id_pat on hisp_pop
(cost=0.28..8.29) (actual time=0.081..0.019 rows loops=1)
Planning time:0.110
Execution time:0.046
```

此场景下规划期判定使用索引会比全表扫描效更高，因此在执行假话中使用了索引扫描策咯。估算的执行时间从`33.48`降到了`8.29`。起始执行时间也不再是`0`，因为规划期需要先扫描索引，燃火才嫩古巴命中记录从磁盘取出来。你可以看到规划期不再需要扫描`1477`条记录，这极大地降低了执行成本。

最终执行的步骤显示时总是排在最前，其中个记录的估算时间和真实时间就是其所有子步骤相应项目之和。子步骤在显示时是按照层级向右逐级缩进的。

`PostgreSQL`有执行计划缓存功能，所以如果我们再次执行此语句，或者执行一个可以共享缓存下来的执行计划的类似语句，那么执行计划的分析时间就会大大减少。

## 策略设置

默认情况下，所有策略设置都已启用，此时规划期因为不受什么约束所以灵活性是最大的。如果你已经对要查询的数据的特点预先有一定了解，那么就可以有针对性地禁用某些策略来优化语句的执行路径。不过请注意，即使你设置了某种策略为禁用，也并不以为规划器就一定不会使用该策略。规划器晋江这些设置当作用户的建议来对待，总重的解释权还是在规划器。

我们有时候会将`enable_nestloop`和`enable_seqscan`这两个设置为禁用，因为这两个执行效率是很低的，不到万不得已不应使用，所以通过禁用这两个设置可以告诉规划器“不到万不得已不要使用这两个策略”。你可以禁用这两种执行策略，但规划期在没有别的选择时还是可能使用的，因为无论如何至少应该保证语句可以正常执行。

如果规划器选择了全表扫描策略，那就意味着后续执行过程中会从头到尾读取表中的每一条记录。规划期会在以下两种情况下选择全表扫描策略：一种情况是表上没有合适的缩影能满足查询条件的要求：另外一种是规划器认为通过索引来查找数据的成本要高于全表扫描。如果你禁用了全表扫描策略， 但规划器依然选择了这么办，这就说明表上无索引或者虽然有缩影但不适用此语句的查询条件。

## 利用pg_stat_statements插件来查询最耗时的语句

```sql
select * from pg_stat_statements as s inner join pg_database as d on d.oid = s.dbid
order by total_time
```

```sql
set enable_seqscan = false
EXPLAIN (ANALYZE)
```

不管将`enable_seqscan`设置启用还是禁用，规划期总是会选择执行全表扫描，因为此时索引无法满足查询条件的需要。

你可能认为规划器又神秘又强大，但无论如何规划器不是神，它只是遵循一套谁都能更好的算法来生成执行计划。关于规划器算法的内容细节已经远远超出本书的范围，在此不做讨论。虽然规划器的算法严重依赖于表的统计信息，但规划器不会在每次生成执行假话之前临时扫描所有的相关表以获取其统计信息，因为如果那么做的话任何语句的执行都将巨慢无比，完全没有执行效率可言，因此规划器会依赖预先搜集好的表统计信息。

要想规划器能够做出准确的决定，即使准确地更新表统计信息是至关重要的。如果统计信息与实际相差太大，规划器就很可能会常常推到出错误的执行计划，最差的情况就是错误地选择了全表扫描策略。一般来说，平均一张表只有`20%`的记录采样率，统计信息会基于这些参与采样的记录来生成。对于非常大的表来说，采样率可能更低。

```sql
select attname as colname,
n_distinct,
most_common_vals as common_vals,
most_common_freqs as dist_freq
from pg_stats
where tablename = 'product'
order by schemaname, tablename, attname
```

`pg_stats`表给出了表中指定列的值域分布图，规划期会根据此信息指定相应的执行计划。系统后台会有一个进程持续不断的更新`pg_stats`表。等表中插入或者删除大量数据之后，你应该手动执行`VACUUM ANALYZE`来跟新表的统计信息。`VACCUM`只是将已经删除的记录永久的从表中删除，`ANALYZE`只是更新表的统计信息。

```sql
alter tablespace pg_default set(random_page_cost=2)
```

另一个会影响执行策略选择的设置是`random_page_cost`（随机页访问比，简称`RPC`），它表示磁盘上顺序读取和随机读取在同一条记录上的性能比。

random_page_cost (floating point)

    Sets the planner's estimate of the cost of a non-sequentially-fetched disk page. The default is 4.0. This value can be overridden for tables and indexes in a particular tablespace by setting the tablespace parameter of the same name (see ALTER TABLESPACE).

    Reducing this value relative to seq_page_cost will cause the system to prefer index scans; raising it will make index scans look relatively more expensive. You can raise or lower both values together to change the importance of disk I/O costs relative to CPU costs, which are described by the following parameters.

    Random access to mechanical disk storage is normally much more expensive than four times sequential access. However, a lower default is used (4.0) because the majority of random accesses to disk, such as indexed reads, are assumed to be in cache. The default value can be thought of as modeling random access as 40 times slower than sequential, while expecting 90% of random reads to be cached.

    If you believe a 90% cache rate is an incorrect assumption for your workload, you can increase random_page_cost to better reflect the true cost of random storage reads. Correspondingly, if your data is likely to be completely in cache, such as when the database is smaller than the total server memory, decreasing random_page_cost can be appropriate. Storage that has a low random read cost relative to sequential, e.g. solid-state drives, might also be better modeled with a lower value for random_page_cost.

如果你之前执行过一个复杂且耗时较长的查询，那么后续再次执行此查询时会发现快了很多，这是因为系统的数据缓存机制发挥了作用。如果同一个出巡语句按顺序多次执行，而且这些查询涉及的底层数据没有发生变化，那么不管这些语句是被同一个用户还是多个用户执行，得到的结果都应该是一样的。只要内存中还有空间可用于缓存数据，那么规划器就可能会跳过生成执行计划和从磁盘读取表数据的步骤，直接从缓存中获取数据。

```sql
select 
count(case when B.isdirty then 1 else null end) as dirty_buffers,
count(*) as num_buffers
from
pg_class as C inner join
pg_buffercache B on C.relfilenode = B.relfilenode inner join
pg_database D on b.reldatabase = D.oid and D.datname = current_database()
group by C.relname
```

`pg_prewarm`会将指定的常用表预加载到缓存中，以后不管该表是搜测i被用户访问还是非首次访问，响应速度总是很快。

新手常常犯的错误就是容易将子查询当作一个完全独立的数据集来使用。`SQL`语言有一个与传统编程语言很不一样的地方，就是`SQL`语言中并没有很强的“黑盒”概念。也就是说，编写一堆互相独立的子查询并把每个子查询当作一个“黑盒”数据块来看待，只要能得到最后结果就行，而不管其他，这种思路是错误的。它实际上割裂了子查询代码快内部处理逻辑与子查询代码快外部处理逻辑之间的联系，没有将整个`SQL`语句当成一个有机的整体来处理。从多个子查询中取数据与从多个表或者视图中取数据是一样中亚昂的。
