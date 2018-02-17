Optimistic locking allows multiple users to access the same record for edits, 
and assumes a minimum of conflicts with the data. It does this by checking 
whether another process has made changes to a record since it was opened, an 
ActiveRecord::StaleObjectError exception is thrown if that has occurred and the 
update is ignored.

Check out ActiveRecord::Locking::Pessimistic for an alternative.
Usage

Active Record supports optimistic locking if the lock_version field is present. 
Each update to the record increments the lock_version column and the locking 
facilities ensure that records instantiated twice will let the last one saved 
raise a StaleObjectError if the first was also updated. Example:
```ruby
p1 = Person.find(1)
p2 = Person.find(1)

p1.first_name = "Michael"
p1.save

p2.first_name = "should fail"
p2.save # Raises an ActiveRecord::StaleObjectError
```
Optimistic locking will also check for stale data when objects are destroyed. 
Example:

p1 = Person.find(1)
p2 = Person.find(1)

p1.first_name = "Michael"
p1.save

p2.destroy # Raises an ActiveRecord::StaleObjectError

You're then responsible for dealing with the conflict by rescuing the exception 
and either rolling back, merging, or otherwise apply the business logic needed 
to resolve the conflict.

This locking mechanism will function inside a single Ruby process. To make it 
work across all web requests, the recommended approach is to add lock_version as 
a hidden field to your form.

This behavior can be turned off by setting 
ActiveRecord::Base.lock_optimistically = false. To override the name of the 
lock_version column, set the locking_column class attribute:
```ruby
class Person < ActiveRecord::Base
  self.locking_column = :lock_person
end
```

把数据存入数据库之前进行验证是十分重要的步骤，所以调用 save 和 update 方法时会做数据验证。验证失败时返回 
false，此时不会对数据库做任何操作。这两个方法都有对应的爆炸方法（save! 和 update!）。爆炸方法要严格一些，如果验证失败，抛出 
ActiveRecord::RecordInvalid 异常。下面举个简单的例子：

add_reference :products, :user, foreign_key: true`

create_join_table 方法用于创建 HABTM（has and belongs to many）联结数据表。典型的用法像下面这样：
create_join_table :products, :categories

上面的代码会创建包含 category_id 和 product_id 字段的 categories_products 数据表。这两个字段的 :null 
选项默认设置为 false，可以通过 :column_options 选项覆盖这一设置：
