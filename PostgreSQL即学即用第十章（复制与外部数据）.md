`PostgreSQL`有很多方法可以实现与外部数据源之间的数据共享。第一种就是`PostgreSQL`自带的复制功能，通过该功能可以在令哇一台服务器上创建出当前服务器的一个镜像。第二种方法是使用第三方插件，其中许多插件可以免费使用，并且其可靠性也是就近考研的。第三种方法是外部数据封装器(Foreign Data Wrapper, FDW)。`FDW`支持大量的外部数据源，有些FDW，比如(`postgres_fdw`和`hadoop_fdw`)也支持对外部数据的修改。

全世界的客户都涌到你的网站来查看并购买，有与流量过大导致网站过载并无法正常处理请求，那么这时候就需要复制功能出马了。只需设定一个只读的丛书服务器作为主服务器的镜像，然后就可以把海量的读请求分流到丛书服务器上，只有当买家真正下单时才需要到主服务器上进行操作。

## 复制功能涉及的术语

- 主服务器
主服务器是作为复制数据源头的数据库服务器，所有的更新都在其上发生。使用`PostgreSQL`的内置功能时，仅允许使用一个主服务器。

- 从属服务器
从属服务器使用复制的数据并提供主服务器的副本。尽管有人谈到一些听起来更悦耳的术语。比如：订阅者(`subscriber`)，代理(`agent`)等，但从属服务器这个名称仍然是最贴切的。

- 预写日志(`Write Ahead Log`)， WAL
WAL就是就是记录所有已完成事务信息的日志文件，在其他数据库产品中一般称为事务日志。为了支持复制功能，`PostgreSQL`将主服务器的`WAL`日志向丛书服务器开放，然后丛书服务器持续地将这些日志取到本地，然后将其中记录的事务重演一遍，这样就实现了数据同步。

- 同步复制
在事务提交阶段，`PostgreSQL`需保证已经将此事务中所做的修改成功同步到至少一个从属服务器，然后才能向用户反馈事务提交成功。这种工作模式保证了主服务器和从属服务器的数据在同一个事务内被同步修改，因此被称为同步复制。如果配置了多个从属服务器，只要写入一个成功就算提交成功。

- 异步复制

在事务提交阶段，主服务器上提交成功就算成功，不需要等待从属服务器的数据跟新成功。当从属服务器位于远端时该模式就比较有用了，因为可以避免网络的影响。但有利必有弊，该模式下从属服务器的数据更新不够及时，与主服务器之间会有一些延迟。当传输失败时，从属服务器可能会丢失一些数据。

- 流式复制

从PG 9.0版本开始支持流式复制。在此前的版本中，`WAL`日志是通过直接复制文件的凡是从主服务器传递到从属服务器，但在流式复制模式下是通过消息来传递的。

- 级联复制

从9.2版本开始，一个从属服务器可以把`WAL`日志传递给另一个从属服务器，而不需要所有的从属服务器都从主服务器取`WAL`日志，这进一步减轻了主服务器的负担。这种模式下，有的从属服务器可以作为同步的数据源从而继续向别的从属服务器传播`WAL`数据，从这个角度下，其作用类似于主服务器。注意，这种扮演着“WAL日志二传手”角色的从属服务器是只读的，它们也被称为从属服务器。

- 重新选主

重新选主是指从所有从属服务器中选择一个并将其身份提升为主服务器的过程。

## wal_level


    wal_level determines how much information is written to the WAL. The default value is replica, which writes enough data to support WAL archiving and replication, including running read-only queries on a standby server. minimal removes all logging except the information required to recover from a crash or immediate shutdown. Finally, logical adds information necessary to support logical decoding. Each level includes the information logged at all lower levels. This parameter can only be set at server start.

    In minimal level, WAL-logging of some bulk operations can be safely skipped, which can make those operations much faster (see Section 14.4.7). Operations in which this optimization can be applied include:
    CREATE TABLE AS
    CREATE INDEX
    CLUSTER
    COPY into tables that were created or truncated in the same transaction

    But minimal WAL does not contain enough information to reconstruct the data from a base backup and the WAL logs, so replica or higher must be used to enable WAL archiving (archive_mode) and streaming replication.

    In logical level, the same information is logged as with replica, plus information needed to allow extracting logical change sets from the WAL. Using a level of logical will increase the WAL volume, particularly if many tables are configured for REPLICA IDENTITY FULL and many UPDATE and DELETE statements are executed.

    In releases prior to 9.6, this parameter also allowed the values archive and hot_standby. These are still accepted but mapped to replica.

Write-Ahead Logging (WAL) is a standard method for ensuring data integrity. A detailed description can be found in most (if not all) books about transaction processing. Briefly, WAL's central concept is that changes to data files (where tables and indexes reside) must be written only after those changes have been logged, that is, after log records describing the changes have been flushed to permanent storage. If we follow this procedure, we do not need to flush data pages to disk on every transaction commit, because we know that in the event of a crash we will be able to recover the database using the log: any changes that have not been applied to the data pages can be redone from the log records. (This is roll-forward recovery, also known as REDO.)
Tip

Because WAL restores database file contents after a crash, journaled file systems are not necessary for reliable storage of the data files or WAL files. In fact, journaling overhead can reduce performance, especially if journaling causes file system data to be flushed to disk. Fortunately, data flushing during journaling can often be disabled with a file system mount option, e.g. data=writeback on a Linux ext3 file system. Journaled file systems do improve boot speed after a crash.

Using WAL results in a significantly reduced number of disk writes, because only the log file needs to be flushed to disk to guarantee that a transaction is committed, rather than every data file changed by the transaction. The log file is written sequentially, and so the cost of syncing the log is much less than the cost of flushing the data pages. This is especially true for servers handling many small transactions touching different parts of the data store. Furthermore, when the server is processing many small concurrent transactions, one fsync of the log file may suffice to commit many transactions.

WAL also makes it possible to support on-line backup and point-in-time recovery, as described in Section 25.3. By archiving the WAL data we can support reverting to any time instant covered by the available WAL data: we simply install a prior physical backup of the database, and replay the WAL log just as far as the desired time. What's more, the physical backup doesn't have to be an instantaneous snapshot of the database state — if it is made over some period of time, then replaying the WAL log for that period will fix any internal inconsistencies.

archive_mode (enum)

    When archive_mode is enabled, completed WAL segments are sent to archive storage by setting archive_command. 


外部数据封装器（FDW）是PostgreSQl提供的一种用于王文外部数据源的手段，他是可扩展的，也兼容业界标准。该机制所支持的外部数据源包括`PostgreSQL`以及其他非`PostgreSQL`数据源。`FDW`是在`9.1`版本引入的，其核心概念是“外部表”，这种表看起来和当前`PostgreSQL`中其他表的用法完全相同，但实际上其数据本体是存在于外部数据源中的，该数据源甚至可能存在于另外一台物理服务器上。一旦定义好了外部表，那么其定义就会在当前数据库中持久化，你就可以放心地与普通表一样使用它，FDW完全屏蔽了与外部数据源之间复杂的通讯过程。

```sql
create extension file_fdw;
create server my_server foreign data wrapper file_fdw;
create foreign table devs (developer varchar(150), company varchar(150)) server my_server options (format 'csv', header 'false', filename 'C:\\tt.txt', delimiter '|', null '');
select * from devs;
```
