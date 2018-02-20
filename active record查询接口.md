take 方法检索一条记录而不考虑排序。例如：
```
  client = Client.take
  # => #<Client id: 1, first_name: "Lifo">
```
:start

记录默认是按主键的升序方式取回的，这里的主键必须是整数。:start 选项用于配置想要取回的记录序列的第一个 ID，比这个 ID 
小的记录都不会取回。这个选项有时候很有用，例如当需要恢复之前中断的批处理时，只需从最后一个取回的记录之后开始继续处理即可。

下面的例子把时事通讯发送给主键从 2000 开始的用户：
```
User.find_each(start: 2000) do |user|
  NewsMailer.weekly(user).deliver_now
end
```

可以使用 unscope 方法删除某些条件

Article.none # 返回一个空 Relation 对象，而且不执行查询
# 下面的 visible_articles 方法期待返回一个空 Relation 对象
@articles = current_user.visible_articles.where(name: params[:name])
 
def visible_articles
  case role
  when 'Country Manager'
    Article.where(country: country)
  when 'Reviewer'
    Article.published
  when 'Bad User'
    Article.none # => 如果这里返回 [] 或 nil，会导致调用方出错
  end
end
```

```
client = Client.readonly.first
client.visits += 1
client.save
```

```
应用的其他部分可能会修改数据，那么应该怎么重载缓存呢？在关联上调用 reload 即可：
author.books                 # 从数据库中检索图书
author.books.size            # 使用缓存的图书副本
author.books.reload.empty?   # 丢掉缓存的图书副本
                             # 重新从数据库中检索
``

Item.transaction do
  i = Item.lock.first
  i.name = 'Jones'
  i.save!
end

对于 MySQL 后端，上面的会话会生成下面的 SQL 语句：
SQL (0.2ms)   BEGIN
Item Load (0.3ms)   SELECT * FROM `items` LIMIT 1 FOR UPDATE
Item Update (0.4ms)   UPDATE `items` SET `updated_at` = '2009-02-07 18:05:56', 
`name` = 'Jones' WHERE `id` = 1
SQL (0.8ms)   COMMIT 

我们可以在关联触发的查询上执行 EXPLAIN 命令。例如：
User.where(id: 1).joins(:articles).explain

class Client < ApplicationRecord
  def name
    "I am #{super}"
  end
end
 
Client.select(:name).map &:name
# => ["I am David", "I am Jeremy", "I am Jose"]
 
Client.pluck(:name)
# => ["David", "Jeremy", "Jose"]

作用域允许我们把常用查询定义为方法，然后通过在关联对象或模型上调用方法来引用这些查询。fotnote:[“作用域”和“作用域方法”在本文中是一个意思。——译者注
]在作用域中，我们可以使用之前介绍过的所有方法，如 where、join 和 includes 方法。所有作用域都会返回 
ActiveRecord::Relation 对象，这样就可以继续在这个对象上调用其他方法（如其他作用域）。

要想定义简单的作用域，我们可以在类中通过 scope 方法定义作用域，并传入调用这个作用域时执行的查询。
class Article < ApplicationRecord
  scope :published, -> { where(published: true) }
end

通过上面这种方式定义作用域和通过定义类方法来定义作用域效果完全相同，至于使用哪种方式只是个人喜好问题：
class Article < ApplicationRecord
  def self.published
    where(published: true)
  end
end

在作用域中可以链接其他作用域：
class Article < ApplicationRecord
  scope :published,               -> { where(published: true) }
  scope :published_and_commented, -> { published.where("comments_count > 0") }
end

我们可以在模型上调用 published 作用域：
Article.published # => [published articles]
