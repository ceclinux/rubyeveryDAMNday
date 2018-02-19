数据验证确保只有有效的数据才能存入数据库。例如，应用可能需要用户提供一个有效的电子邮件地址和邮寄地址。在模型中做验证是最有保障的，只有通过验证的数据才能存入数据
库。数据验证和使用的数据库种类无关，终端用户也无法跳过，而且容易测试和维护。在 Rails 中做数据验证很简单，Rails 
内置了很多辅助方法，能满足常规的需求，而且还可以编写自定义的验证方法。

Rails 团队认为，模型层数据验证最具普适性

```
$ bin/rails console
>> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>
>> p.new_record?
=> true
>> p.save
=> true
>> p.new_record?
=> false
```

新建并保存记录会在数据库中执行 SQL INSERT 操作。更新现有的记录会在数据库中执行 SQL UPDATE 操作。一般情况下，数据验证发生在这些 SQL 
操作执行之前。如果验证失败，对象会被标记为无效，Active Record 不会向数据库发送 INSERT 或 UPDATE 
指令。这样就可以避免把无效的数据存入数据库。你可以选择在对象创建、保存或更新时执行特定的数据验证。

你还可以自己执行数据验证。valid? 方法会触发数据验证，如果对象上没有错误，返回 true，否则返回 false。前面我们已经用过了：
class Person < ApplicationRecord
  validates :name, presence: true
end
 
Person.create(name: "John Doe").valid? # => true
Person.create(name: nil).valid? # => false

Active Record 执行验证后，所有发现的错误都可以通过实例方法 errors.messages 
获取。该方法返回一个错误集合。如果数据验证后，这个集合为空，说明对象是有效的。

若想检查对象的某个属性是否有效，可以使用 errors[:attribute]。errors[:attribute] 中包含与 :attribute 
有关的所有错误。如果某个属性没有错误，就会返回空数组。
这个方法只在数据验证之后才能使用，因为它只是用来收集错误信息的，并不会触发验证。与前面介绍的 ActiveRecord::Base#invalid? 
方法不一样，errors[:attribute] 不会验证整个对象，只检查对象的某个属性是否有错。

2.2 validates_associated

如果模型和其他模型有关联，而且关联的模型也要验证，要使用这个辅助方法。保存对象时，会在相关联的每个对象上调用 valid? 方法。
```
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

这个方法检查表单提交时，用户界面中的复选框是否被选中。这个功能一般用来要求用户接受应用的服务条款、确保用户阅读了一些文本，等等。
```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

如果模型和其他模型有关联，而且关联的模型也要验证，要使用这个辅助方法。保存对象时，会在相关联的每个对象上调用 valid? 方法。
```
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```
