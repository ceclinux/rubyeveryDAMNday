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

列出安装了哪些扩展包

```sql
select name, default_version, installed_version, left(comment, 30) AS comment
from pg_available_extensions
where installed_version is not null
order by name;
```

如果你想了解系统中某个已安装包的跟多详细内容，有哪些额外的函数，可以在`psql`中执行类似以下的命令

```
\dx+ adminpack
```

安装扩展包`fuzzystrmatch`

```sql
create extension fuzzystrmatch
```

创建具有登陆权限的角色

```sql
create role leo login password 'king' createdb valid until 'infinity'
```
`VALID`行是可选的，其功能是为此角色的权限设定有效期，过期后所有权限都失效，默认时限是`infinity`，即永不过期。`CREATEDB`修饰符表明为此角色赋予了创建新数据库的权限。

```sql
create role regina login password 'queen' superuser valid until '2020-1-1 00:00'
```
上面的语句中，我们创建了一个拥有至高无上权力的超级用户"queen"，但我们又不希望这位"queen"永远”统治”下去，那么怎么办呢？ 用`VALID`子句给他的权力加一个期限好了。


```sql
create role royalty inherit
```
请注意术语`INHERIT`的用法。它表示组角色`royalty`的任何一个成员角色都将自动继承其除“超级用户权限”外的所有权限。`Postgres`不允许超级用户权限通过继承的方式传递。

有些权限是无法被继承的，例如前面提到过的`SUPERUSER`超级用户权限就无法被继承。然而成员角色可以通过`SET ROLE`命令来实现“冒名顶替”其父角色的身份，从而获得其父角色所拥有的`SUPERUSER`权限，当然这种冒名顶替的状态是有期限的，仅限于当前会话存续期间有效。例如，`royalty`组角色的成员角色可以通过执行以下语句来实现上述“冒名顶替”的目的。

```sql
set role royalty
```

1. 首先，只有具备`SUPERUSER`权限的用户才可以执行`SET SESSION AUTHORIZATION`，而`SET ROLE`是任何一个成员角色都可以执行的。其次，`SET SESSION AUTHORIZATION`能够使当前角色“扮演”系统中任何一个其他角色，即当前角色可以拥有其他目标角色的身份和相应权限，而不像`SET ROLE`那样仅仅限于“扮演”其父角色。

2. 从系统内部实现机制来讲，每个会话会有两个表示当前用户身份的环境变量：一个是`session_user`，即当前用户登录时带的原始身份，一个是`current_user`，即当前用户所扮演的身份，默认情况下两者是一致的。`SET SESSION AUTHORIZATION`命令会将`current_USER`和`session_user`都替换为所“扮演”角色的相应身份ID，而`SET ROLE`命令只会修改`current_user`，而保持`session_user`不变。这意味者`SET SESSION AUTHORIZATION`命令会对后续的`SET ROLE`命令产生影响，因为原始身份`session_user`也发生了变化；而`SET ROLE`命令不会对后续的`SET ROLE`命令产生影响，因为原始身份`session_user`未发生变化。

3. 假设某会话的原始身份是`ROLE_A`，即`current_user`和`session_user`都是`ROLE_A`，然后成功执行了`SET SESSION AUTHORIZATION ROLE_B`命令，那么`current_user`和`session_user`都被修改成了`ROLE_B`，之后如果在此会话上再执行`SET ROLE`命令的话，基础身份就是`ROLE_B`了，也就是说此时`SET ROLE`只能设定为`ROLE_B`所归属的某个组角色。但由于`SET ROLE`并不修改`session_user`标识，因此在执行过`SET ROLE`之后再执行`SET ROLE`的话，后一个`SET ROLE`操作的基础身份是不变的，还是当前的`session_user`角色。

## 创建`database`

最基本的创建数据库的`SQL`语句是：

```sql

CREATE DATABASE mydb;
```

该命令会以`template1`库为模板生成一份副本作为新`database`，每个`database`都会有一个属主，这个新库的属主就是执行此`SQL`命令的角色。任何一个拥有`CREATEDB`权限的角色都能够创建新的`database`。

创建新`database`时，`PostgreSQL`会基于模板数据库制作一份副本，其中会包含所有的数据库设置和数据文件。

基于某个模板创建数据库的基本语法如下

```sql
CREAtE DATABASE my_db TEMPLATE my_template_db
```
