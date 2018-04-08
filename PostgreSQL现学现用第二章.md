`postgresql.conf`文件包含了`PostgreSQL`服务能够正常运行所必需的基础设施以及新建数据库时所使用的默认设置。


```sql
select name, context, unit, setting,boot_val,reset_val
from pg_settings
where name in ('listen_addresses', 'max_connections','shared_buffers', 'effective_cache_size', 'work_mem', 'maintenance_work_mem')
order by context, name;
```

`unit`字段表示这些设置的单位，`setting`是指当前的设置，`boot_val`是指默认设置

## shared_buffers

此设置定义了用于缓存最近访问过的数据页的内存区大小，所有用户会话**均可共享此缓存区**。此设置对查询速度有着重大影响，一般来说是越大越好。

## effective_cache_size

此设置表示一个查询执行过程中可以使用的最大内存，包括操作系统使用的部分以及`PostgreSQL`使用的部分。系统并不会根据这个值来真实的分配这么多内存，但是规划器会根据这个值来判断系统能否提供查询执行过程中所需的内存。如果将此设置的过小，远远小于系统真实可用内存量，那么可能会给规划器造成误导，让规划器认为系统可用内存有限，从而选择不适用索引而是走全表扫描（因为使用索引虽然快，但需要占用更多的中间内存）。

## work_mem

此设置制定了用于执行顺序、哈希关联、表扫描等操作的最大内存量。要得到此设置的最优值需要考虑以下一些因素：数据库的使用方式，需要预留多少内存给除数据库系统外的程序，以及服务器是否专用于运行`postgresql`服务等问题。

上述设置可在库级、用户级以及函数级设置。例如，如果有一个精通`SQL`的用户要在库上执行非常复杂的`SQL`语句，那么可以为此用户单独调大`work_mem`的值。又比如有一个函数有很多排序操作，那么可以为此函数调大`work_mem`的值。
