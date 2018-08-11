1. 需要将多个条目对应一个键吗?
如果是，那么需要使用`keyword`模块
2. 需要保证元素次序吗
如果还是，则选择`keyword`模块
3. 需要对内容进行模式匹配吗
如果是，则使用散列表
4. 需要存储数百个的条目吗
如果是，使用`HashDict`

散列表和散列字典都实现了`Dict`的行为。`Keyword`模块也基本实现了，不同之处在于它支持重复键。HashDict is deprecated. Use the Map module instead.

```elixir
defmodule Sum do
  def values(dict) do
    dict |> Dict.values |> Enum.sum
  end
end

hd = [one: 1, two: 2, three: 3] |> Enum.into HashDict.new
IO.puts Sum.values(hd) # 6

map = %{four: 4, five: 5, six: 6}
IO.puts Sum.values(map) # 15

ke_list = [name: "Dave", likes: "Programming", where: "Dallas"]
hashdict = Enum.into ke_list, Map.new
%{likes: "Programming", name: "Dave", where: "Dallas"}

iex|6 ▶ ke_list[:likes]
"Programming"

%{likes: "Programming", name: "Dave", where: "Dallas"}
iex|9 ▶ hashdict = Map.drop(hashdict, [:where, :likes])

iex|12 ▶ Map.put(hashdict, :also_likes, "Ruby")
%{also_likes: "Ruby", name: "Dave"}
```

关键字列表允许出现重复的值，但是要使用`Keyword`模块才能访问他们

```elixir
iex|13 ▶ kw_list = [name: "Dave", likes: "Programming", likes: "Elixir"]
[name: "Dave", likes: "Programming", likes: "Elixir"]
iex|14 ▶ kw_list[:likes]
"Programming"
iex|17 ▶ Keyword.get_values(kw_list, :likes)
["Programming", "Elixir"]
iex|20 ▶ person = %{name: "Dave", height: 1.88}
%{height: 1.88, name: "Dave"}
iex|21 ▶ %{name: _, height: _} = person
%{height: 1.88, name: "Dave"}
iex|22 ▶ %{name: _, weight: _} = person

▶▶▶
** (MatchError) no match of right hand side value: %{height: 1.88, name: "Dave"}
    (stdlib) erl_eval.erl:450: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:250: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:230: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:208: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:94: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:24: IEx.Evaluator.init/4

    iex|22 ▶ people = [
...|22 ▶ %{name: "Grumpy", height: 1.24},
...|22 ▶ %{name: "Dave", height: 1.88},
...|22 ▶ %{name: "Dopey", height: 1.32},
...|22 ▶ %{name: "Shaquilee", height: 2.16},
...|22 ▶ %{name: "Sneezy", height: 1.28}
...|22 ▶ ]
[
  %{height: 1.24, name: "Grumpy"},
  %{height: 1.88, name: "Dave"},
  %{height: 1.32, name: "Dopey"},
  %{height: 2.16, name: "Shaquilee"},
  %{height: 1.28, name: "Sneezy"}
]
iex|23 ▶ for person = %{height: height} <- people,
...|23 ▶ height > 1.5

▶▶▶
** (CompileError) iex:23: missing :do option in "for"

iex|23 ▶ for person = %{height: height} <- people,
...|23 ▶ height > 1.5,
...|23 ▶ do: IO.inspect person
%{height: 1.88, name: "Dave"}
%{height: 2.16, name: "Shaquilee"}
[%{height: 1.88, name: "Dave"}, %{height: 2.16, name: "Shaquilee"}]
```

在这段代码中，我们将一个由散列表组成的列表提供给推导式（comprehension）。生成器（generator）将每个散列表（作为整体）绑定到`person`，并且将散列表获得的高度值绑定到`height`。过滤器率选那些高度超过1.5的散列表。

## 更新散列表

```elixir
m = %{a: 1, b: 2, c: 3}
m1 = %{ m | b: "two", c: "three"}
# %{a: 1, b: "two", c: "three"}
```
然而，此语法无法向散列表增加新的键值。要增加新的建值，你需要使用`Dict.put_new`

```elixir
defmodule Subscriber do
  defstruct name: "", paid: false, over_18: true
end

iex|6 ▶ s1 = %Subscriber{}
%Subscriber{name: "", over_18: true, paid: false}
iex|7 ▶ s2 = %Subscriber{ name: "Dave"}
%Subscriber{name: "Dave", over_18: true, paid: false}
iex|8 ▶ s3 = %Subscriber{ name: "Mary", paid: false}
%Subscriber{name: "Mary", over_18: true, paid: false}
iex|9 ▶ s3 = %Subscriber{ name: "Mary", paid: true}
%Subscriber{name: "Mary", over_18: true, paid: true}
```

可以用点记和模式匹配来访问字段

```elixir
iex|10 ▶ s3.name
"Mary"

iex|11 ▶ %Subscriber{name: a_name} = s3
%Subscriber{name: "Mary", over_18: true, paid: true}
iex|12 ▶ a_name
"Mary"
```

```elixir

defmodule Attendee do
  defstruct name: "", paid: false, over_18: true

  def may_attend_after_party(attendee = %Attendee{}) do
    attendee.paid && attendee.over_18
  end

  def print_vip_badge(%Attendee{name: name}) when name != "" do
    IO.puts "Very cheap badge for #{name}"
  end

  def print_vip_badge(%Attendee{}) do
    raise "missing name for badge"
  end
end
```

```elixir
iex|1 ▶ a1 =  %Attendee{name: "Dave", over_18: true}
%Attendee{name: "Dave", over_18: true, paid: false}

iex|5 ▶ a2 = %Attendee{a1| paid: true}
%Attendee{name: "Dave", over_18: true, paid: true}

iex|6 ▶ Attendee.may_attend_after_party(a2)
true
```

```elixir
iex|7 ▶ a3 = %Attendee{}
%Attendee{name: "", over_18: true, paid: false}
iex|8 ▶ Attendee.print_vip_badge(a3)

▶▶▶
** (RuntimeError) missing name for badge
    defstruct1.exs:13: Attendee.print_vip_badge/1
```

前面的例子在访问结构体的属性时使用了点符号。这可能让你感到奇怪，结构体的散列表有很多共同点，然而访问散列表却使用的是`some_map[:name]`

#嵌套字典结构

```elixir
iex|1 ▶ report = %BugReport{owner: %Customer{name: "Dave", company: "Pragmatic"}, details: "broken"}
%BugReport{
  details: "broken",
  owner: %Customer{company: "Pragmatic", name: "Dave"},
  severity: 1
}

iex|4 ▶ report.owner.company
"Pragmatic"

iex|6 ▶ report = %BugReport{ owner: %Customer { report.owner| company: "PragProg"}}
%BugReport{
  details: "",
  owner: %Customer{company: "PragProg", name: "Dave"},
  severity: 1
}

iex|2 ▶ put_in(report.owner.company, "Fack")
%BugReport{
  details: "broken",
  owner: %Customer{company: "Fack", name: "Dave"},
  severity: 1
}

iex|3 ▶ report2 = %{owner: %{name: "Dave", company: "Pragmatic"}, severity: 1}
%{owner: %{company: "Pragmatic", name: "Dave"}, severity: 1}

iex|4 ▶ put_in(report2[:owner][:company], "PragProg")
%{owner: %{company: "PragProg", name: "Dave"}, severity: 1}

#HashSet<[2, 3, 4, 1, 5]>
iex|6 ▶ set1 = Enum.into 1..5, MapSet.new
#MapSet<[1, 2, 3, 4, 5]>
iex|7 ▶ Set.member? set1, 3
warning: Set.member?/2 is deprecated, use the MapSet module for working with sets
  iex:7

true
iex|8 ▶ MapSet.member? set1, 3
true
iex|9 ▶ set2 = Enum.into 3..8, HashSet.new
warning: HashSet.new/0 is deprecated, use the MapSet module instead
  iex:9

#HashSet<[7, 6, 3, 4, 5, 8]>
iex|10 ▶ Set.intersection set1, set2
warning: Set.intersection/2 is deprecated, use the MapSet module for working with sets
  iex:10

#MapSet<[3, 4, 5]>
iex|11 ▶
```

```elixir
iex|14 ▶ list = Enum.to_list 1..5
[1, 2, 3, 4, 5]
iex|15 ▶ Enum.map list, &(&1 * 10)
[10, 20, 30, 40, 50]
iex|16 ▶ Enum.map list, &String.duplicate("*", &1)
["*", "**", "***", "****", "*****"]
```

```elixir
iex|1 ▶ s = Stream.map [1,3,5,6], &(&1 + 1)
#Stream<[
  enum: [1, 3, 5, 6],
  funs: [#Function<48.100999549/1 in Stream.map/2>]
]>
iex|2 ▶ Enum.to_list s
[2, 4, 6, 7]
```

由于流是可枚举的，你也可以将流传给流函数。正因为这样，我们说流是可组合的（composable）

```elixir
iex|5 ▶ [1,2,3,4] |>
...|5 ▶ Stream.map(&(&1*&1)) |>
...|5 ▶ Stream.map(&(&1+1)) |>
...|5 ▶ Stream.filter(fn x -> rem(x,2) == 1 end) |>
...|5 ▶ Enum.to_list
[5, 17]
```
