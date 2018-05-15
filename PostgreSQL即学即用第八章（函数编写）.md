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

`IMMUTABLE`任何情况下，只要调用该函数时使用相同的输入就会得到相同的输出

```
CREATE OR REPLACE FUNCTION
update_logs(log_id int, param_user_name varchar, param_description text)
RETURNS void AS
$$
UPDATE logs SET user_name = $2, description = $3
$$
LANGUAGE 'sql' VOLATILE;
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

```sql
create or replace function geom_mean_final(numeric[2])
returns numeric as
$$
select case when $1[2] > 0 then exp($1[1] / $1[2]) else 0 end;
$$
language sql immutable
```

```sql
create aggregate geom_mean(numeric)(
sfunc = geom_mean_state,
stype = numeric[],
finalfunc=geom_mean_final,
initcond = '{0,0}'
)
```

`SFUNC`状态切换函数（这个名称不够直观，此处所谓的“状态”是指在聚合运算过程中每处理玩一条记录后得到的中间结果）是实现聚合运算的逻辑主体，它会将自身上一次被调用后生成的计算结果作为本次计算的输入，同时输入的还有当前新一条的待处理记录，这样所将所有记录一条条累计处理完毕后，就得到了基于整个目标记录集的“状态”，也就是最终的聚合结果。有的情况下，`SFUNC`处理得到的结果就是聚合函数需要的最终结果，但另外一些情况下`SFUNC`处理完毕的结果还需要在进行最终加工才是我们想要的聚合结果，`FINALFUNC`就是负责这个最终加工步骤的函数。`FINALFUNC`是可选的，由于它的作用是对`SFUNC`函数的输出结果做最后加工，因此该函数的输入一定是`SFUNC`函数的输出。

第一步是写一个触发器函数
```sql
create or replace function trig_time_stamper() returns trigger as
$$
begin
 new.upd_ts := CURRENT_TIMESTAMP;
 return new;
 end;
 $$
 language plpgsql volatile;
 ```
 
 第二步是将此触发器函数显式附加到合适的触发器上。
 
 ```sql
 create trigger trig_1
before insert or update of user_name,description
on logs
for each row execute procedure trig_time_stamper();
```

这里实现了字段级触发
 
