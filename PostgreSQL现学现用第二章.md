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

你可以用热河一个现存的`database`作为创建新数据库的模板。此外，你还可以将某个现存的数据库标记为模板数据库，对于这种模板的数据库，`PostgreSQL`会禁止对其进行编辑或者删除。任何一个具备`CREATEDB`权限的角色都可以使用这种模板数据库。以超级用户身份运行以下`SQL`可使任何数据库成为模板数据库。

```sql
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'mydb'
```

如果你希望修改或者删除被标记为模板的数据库，请先将上述语句中的`datistemplate`字段值改为`FALSE`，这样就可以放开编辑限制。如果你还希望将此数据库作为模板的话，修改完记得将此字段改回来。

`schema`可以对`database`中的对象进行逻辑分组管理。如果你的服务器上有一堆的`database`，那么管理起来会很麻烦，可以考虑通过`schema`来对数据进行分类并全部存放到一个`database`中。`schema`中的对象名不允许重复，但一个`database`的不同`schema`中的对象是可以重名的。如果你将数据库中的所有表都塞到`public schema`中（建数据库默认创建的`schema`），迟早会遇到对象重名的问题。例如：假设要为一家航空公司设计`IT`系统，那么可以将飞机信息表及其日常维护信息表放到一个叫做`plane`的`schema`中，把所有机组人员及其人事放到人事`schema`中，再创建一个单独`schema`用于记录乘客相关信息，这样就把所有信息分门别类隔离开了。

假设你的工作是开发一套“宠物狗信息管理系统”并将该在线系统租赁给宠物店SPA店使用。每个宠物店的数据必须完全隔离。为了达到这个要求，你可以为每家客户都简历一个单独的`schema`，每个`schema`中建立相同的一张`dogs`表。最后为每个`schema`创建一个与之同名的角色，这样就可以实现各自独自管理。

What is the search path?

Per documentation:

    [...] tables are often referred to by unqualified names, which consist of just the table name. The system determines which table is meant by following a search path, which is a list of schemas to look in.

Bold emphasis mine. This explains identifier resolution, and the “current schema” is, per documentation:

    The first schema named in the search path is called the current schema. Aside from being the first schema searched, it is also the schema in which new tables will be created if the CREATE TABLE command does not specify a schema name.

Bold emphasis mine. The system schemas pg_temp (schema for temporary objects of the current session) and pg_catalog are automatically part of the search path and searched first, in this order. Per documentation:

    pg_catalog is always effectively part of the search path. If it is not named explicitly in the path then it is implicitly searched before searching the path's schemas. This ensures that built-in names will always be findable. However, you can explicitly place pg_catalog at the end of your search path if you prefer to have user-defined names override built-in names.

Bold emphasis as per original. And pg_temp comes before that, unless it's put into a different position.
How to set it?

You have various options to actually set the runtime variable search_path.

    Set a cluster-wide default for all roles in all databases in postgresql.conf (and reload). Careful with that!

    search_path = 'blarg,public'

    The shipped default for this setting is:

    search_path = "$user",public

        The first element specifies that a schema with the same name as the current user is to be searched. If no such schema exists, the entry is ignored.

    Set it as default for one database:

    ALTER DATABASE test SET search_path = blarg,public;

    Set it as default for the role you connect with (effective cluster-wide):

    ALTER ROLE foo SET search_path = blarg,public;

    Or even (often best!) as default for the role only in a given database:

    ALTER ROLE foo IN DATABASE test SET search_path = blarg,public;

    Write the command at the top of your script (Or execute it at any point in your session:

    SET search_path = blarg,public;

    Set a specific search_path for the scope of a function (to be safe from malicious users with sufficient privileges). Read about Writing SECURITY DEFINER Functions Safely in the manual.

CREATE FUNCTION foo() RETURNS void AS
$func$
BEGIN
   -- do stuff
END
$func$ LANGUAGE plpgsql SECURITY DEFINER
       SET search_path=blarg,public,pg_temp;

Higher number in my list trumps lower number.
The manual has even more ways, like setting environment variables or using command-line options.

To see the current setting:

SHOW search_path;

To reset it:

RESET search_path;

Per documentation:

    The default value is defined as the value that the parameter would have had, if no SET had ever been issued for it in the current session.

