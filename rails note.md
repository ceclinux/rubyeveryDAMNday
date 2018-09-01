
Assigns to attribute the boolean opposite of attribute?. So if the predicate returns true the attribute will become false. This method toggles directly the underlying value without calling any setter. Returns self.

Example:
```ruby
user = User.first
user.banned? # => false
user.toggle(:banned)
user.banned? # => true
```

The :counter_cache option can be used to make finding the number of belonging objects more efficient. Consider these models:
class Book < ApplicationRecord
  belongs_to :author
end
class Author < ApplicationRecord
  has_many :books
end

With these declarations, asking for the value of @author.books.size requires making a call to the database to perform a COUNT(*) query. To avoid this call, you can add a counter cache to the belonging model:
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end
class Author < ApplicationRecord
  has_many :books
end

With this declaration, Rails will keep the cache value up to date, and then return that value in response to the size method.

Although the :counter_cache option is specified on the model that includes the belongs_to declaration, the actual column must be added to the associated (has_many) model. In the case above, you would need to add a column named books_count to the Author model.

You can override the default column name by specifying a custom column name in the counter_cache declaration instead of true. For example, to use count_of_books instead of books_count:
class Book < ApplicationRecord
  belongs_to :author, counter_cache: :count_of_books
end
class Author < ApplicationRecord
  has_many :books
end

You only need to specify the :counter_cache option on the belongs_to side of the association.

Counter cache columns are added to the containing model's list of read-only attributes through attr_readonly.
4.1.2.4 :dependent

If you set the :dependent option to:

    :destroy, when the object is destroyed, destroy will be called on its associated objects.
    :delete, when the object is destroyed, all its associated objects will be deleted directly from the database without calling their destroy method.

You should not specify this option on a belongs_to association that is connected with a has_many association on the other class. Doing so can lead to orphaned records in your database.
4.1.2.5 :foreign_key

By convention, Rails assumes that the column used to hold the foreign key on this model is the name of the association with the suffix _id added. The :foreign_key option lets you set the name of the foreign key directly:
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                        foreign_key: "patron_id"
end

In any case, Rails will not create foreign key columns for you. You need to explicitly define them as part of your migrations.

```ruby
require 'active_support'
class Record
  include ActiveSupport::Callbacks
  define_callbacks :save

  def save
    p 'none'
    run_callbacks :save do
      puts "- save"
    end
  end
end

class PersonRecord < Record
  set_callback :save, :before, :saving_message
  def saving_message
    puts "saving..."
  end

  set_callback :save, :after do |object|
    puts "saved"
  end
end

person = PersonRecord.new
person.save

```

```
"none"
saving...
- save
saved
```
