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


All About Foreign Keys

The concept of “foreign keys” in the Rails world has quite the potential to 
confuse, because, depending on the context of use, the intended meaning might 
actually differ! In addition, you might find yourself wondering how things like 
“references”, “foreign keys”, “associations” and “joins” are different, and why 
you should use one or not use the other.

You’ve probably reached a point in your Rails life where you want to understand 
more about how ActiveRecord works with your database. As you’ve become familiar 
with the ActiveRecord API, you have built up an intuition about how things work, 
but you know that to build efficient and elegant web applications with Ruby and 
Rails, it will benefit you greatly to deepen your understanding.
Foreign Keys

A foreign key is a mechanism that you can use to associate one table to another. 
Typically, it takes the form of a column with the name <other_table_name>_id. 
Let’s say you have a User table and a Project table, and you’ve used a has_many 
on User, you’ll see that a statement like user.projects when translated into SQL 
by ActiveRecord will automatically use user_id as a foreign key. Check it out 
yourself and see, try:

user.projects.to_sql

in your console. You should see an SQL statement that is searching for all 
projects with a user_id corresponding to user‘s ID.

ActiveRecord relies on this column to figure out which projects of all in the 
projects table are “related” or “associated” to the given user.

You probably know that doing has_many is not enough. You will also have to add a 
column to the Project table with the name user_id. Your migration might look 
like:

add_column :projects, :user_id, :integer

Newer versions of ActiveRecord also provide the #references and #add_reference 
method, which take care of adding the foreign key column for you. So, instead of 
using the add_column method, you can use the add_reference method, like so:

add_reference :projects, :user

This will add a user_id column to the projects table. The advantage with using 
the reference method is that you can add an index and a database constraint on 
the foreign key painlessly as well.

Check out this doc and this doc for more info.
Referential Integrity

If you were wondering what I meant when I said ‘database constraint on the 
foreign key’, rest assured, because I’m going to cover what that means here.

It depends on who you’re talking to, but in many contexts, a foreign key in the 
Rails world is understood plainly as the column itself. Depending on your use 
case, this could be enough. Keep in mind though, that the problem with this 
approach is that when we only have a foreign key column, we have no way of 
ensuring that for a given value of user_id, a corresponding User record actually 
exists. This has the potential to lead to confusion down the line.

To know what I mean, fire up your console and try the following (assuming you 
have the same setup as above, and that we have one User in the system with ID = 
1)

project = Project.create(name: 'hit song', user_id: 2)

You should be able to create the project, but when you do project.user, you’ll 
get back nil. AKA an orphaned project. You can solve this with a validates in 
your model to ensure uniqueness and/or presence of the user, but you might find 
yourself in a situation where you’re bypassing validation callbacks somehow 
(probably with a bulk operation), and yet again creating orphans.

What solves this problem, is getting the database to ensure that orphaned 
records are not created.

Enter the add_foreign_key method, which you’ll notice is sort of a second 
meaning for the term ‘foreign key’. Using this method in your migration tells 
the database (in the way only ActiveRecord knows how) to enforce referential 
integrity by adding a foreign key constraint.

This very good article from the robots at thoughtbot goes into many of the finer 
details of this concept, and why it’s important.

You’d use it like so:

add_column :projects, :user_id
add_foreign_key :projects, :users

This Rails doc gives some additional details.

If you’re using the add_reference method, you can pass in a boolean to indicate 
if a foreign key constraint is to be added, like so:

add_reference :projects, :user, foreign_key: true

有时，迁移执行的操作是无法撤销的，例如删除数据。在这种情况下，我们可以在 down 块中抛出 
ActiveRecord::IrreversibleMigration 异常。这样一旦尝试撤销迁移，就会显示无法撤销迁移的出错信息。

class ExampleMigration < ActiveRecord::Migration[5.0]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end
 
    reversible do |dir|
      dir.up do
        # 添加 CHECK 约束
        execute <<-SQL
          ALTER TABLE distributors
            ADD CONSTRAINT zipchk
              CHECK (char_length(zipcode) = 5) NO INHERIT;
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE distributors
            DROP CONSTRAINT zipchk
        SQL
      end
    end
 
    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
end

可以使用 up 和 down 方法以传统风格编写迁移而不使用 change 方法。up 方法用于描述对数据库模式所做的改变，down 方法用于撤销 up 
方法所做的改变。换句话说，如果调用 up 方法之后紧接着调用 down 方法，数据库模式不会发生任何改变。例如用 up 方法创建数据表，就应该用 down 
方法删除这个数据表。在 down 方法中撤销迁移时，明智的做法是按照和 up 方法中操作相反的顺序执行操作。下面的例子和上一节中的例子的功能完全相同

请注意，执行 db:migrate 任务时会自动执行 db:schema:dump 任务，这个任务用于更新 db/schema.rb 文件，以匹配数据库结构。

迁移尽管很强大，但并非数据库模式的可信来源。Active Record 通过检查数据库生成的 db/schema.rb 文件或 SQL 
文件才是数据库模式的可信来源。这两个可信来源不应该被修改，它们仅用于表示数据库的当前状态。

数据库模式转储有两种方式，可以通过 config/application.rb 文件的 config.active_record.schema_format 
选项来设置想要采用的方式，即 :sql 或 :ruby。

Active Record 在模型而不是数据库中声明关联。因此，像触发器、约束这些依赖数据库的特性没有被大量使用。

验证，如 validates :foreign_key, uniqueness: true，是模型强制数据完整性的一种方式。在关联中设置 :dependent 
选项，可以保证父对象删除后，子对象也会被删除。和其他应用层的操作一样，这些操作无法保证引用完整性，因此有些人会在数据库中使用外键约束以加强数据完整性。

尽管 Active Record 并未提供用于直接处理这些特性的工具，但 execute 方法可以用于执行任意 SQL。
