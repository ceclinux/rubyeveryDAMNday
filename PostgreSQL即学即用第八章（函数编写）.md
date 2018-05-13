再大多数数据库中，你都可以把若干`SQL`语句组合再一起然后将其作为一个单元来处理。`PostgreSQL`也有这种能力。这种机制再不同数据库中的名称不一样，有的叫储存过程，有的叫用户自定义函数等名称，而`PostgreSQL`统一称之为函数。

任何一个功能健全的数据库都支持触发器功能。借助触发器机制可以实现自动捕捉数据变化并进行相应处理。`PostgreSQL`即支持对表建触发器也支持对视图建触发器。

可以指定触发器再语句级或者记录级被触发。对于语句级触发器来说，每执行一条`SQL`语句只会被触发一次；对记录级触发器来说，`SQL`语句执行过程中每修改一条记录就回被触发一次。例如，假设你对某表执行了一个`UPDATE`语句，更新了`1500`条记录，那么该表上的语句级触发器指挥被触发一次，而记录级触发器则会被触发`1500`次。

你还可以更加精细化设置触发器的触发时机，系统支持`Before`，`After`以及`INSTEAD OF`这三种时机。`INSTEAD OF`类触发器会将原语句的操作内容替换调。

你还可以再定义触发器时加上`WHEN`条件来限定只有那些满足了筛选条件的记录被修改时才激活该触发器。

`PostgreSQL`提供了一种专门用于处理触发器逻辑的函数，这类函数被称为触发器函数，其行为模式与其他函数完全类似。内部的代码结构也相同。触发器函数与普通函数的唯一区别在于输入形参和输出类型。触发器函数从不需要实参，因为可以再函数内部访问数据并对其进行修改。

触发器函数的返回值永远是`trigger`类型。`PostgreSQL`的触发器函数与别的普通函数机制完全类似，因此一个触发器函数可以被多个触发器共用。

```sql
create or replace function write_to_log(param_user_name varchar, param_description text)
returns integer as
$$
insert into logs(user_name, description) values($1, $2)
returning id
$$
language 'sql' volatile;
```

```sql
select write_to_log('alejandro', 'Woke up at noon.') as new_id
|new_id|
|4|
```

`VOLATILE`表示结果不稳定，即使是每次使用相同的输入也是这样。

基本上所有编程语言编写的函数都支持返回结果集，`SQL`函数也不例外，它有三种返回结果集的方法；第一种是`ANSI SQL`标准中的规定的`RETURNS TABLE`方法，第二种是使用`OUT`行参，第三种是使用复合数据类型。

```sql
create or replace function select_logs_so(param_user_name varchar)
returns setof logs as
$$
select * from logs where user_name = $1
$$
language 'sql' stable
```

```sql
select * from select_logs_so('alejandro')
```

```sql
create or replace function geom_mean_state(prev numeric[2],next numeric)
returns numeric[2] as
$$
select
case
when $2 IS null or $2 = 0 then $1
else array[coalesce($1[1],0) + ln($2), $1[2] + 1]
end;
$$
language sql immutable
```

此处定义的状态切换函数有两个输入项：第一个是前次调用本转台切换函数计算后得到的结果，其类型为两个元素的数字型数组，第二个是本轮计算要处理的样本值。如果第二个实参的数值为`NULL`或者为`0`,则本轮无需计算，直接返回实参1的值，否则样本将本次处理的样本数字的`ln`对数雷家到实参数据的第一个元素上，并对实参数组的第二个元素指加`1`。
