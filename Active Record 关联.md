## 2.7 在 belongs_to 和 has_one 之间选择

如果想建立两个模型之间的一对一关系，要在一个模型中添加 belongs_to，在另一模型中添加 has_one。但是怎么知道在哪个模型中添加哪个呢？

二者之间的区别是在哪里放置外键（外键在 belongs_to 关联所在模型对应的表中），不过也要考虑数据的语义。has_one 的意思是某样东西属于我，即哪个东西指向你。例如，说供应商有一个账户，比账户拥有供应商更合理，所以正确的关联应该这么声明：
class Supplier < ApplicationRecord
  has_one :account
end
 
class Account < ApplicationRecord
  belongs_to :supplier
end

## 在 has_many :through 和 has_and_belongs_to_many 之间选择

Rails 提供了两种建立模型之间多对多关系的方式。其中比较简单的是 has_and_belongs_to_many，可
以直接建立关联：
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end
 
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end

第二种方式是使用 has_many :through，通过联结模型间接建立关联：
class Assembly < ApplicationRecord
  has_many :manifests
  has_many :parts, through: :manifests
end
 
class Manifest < ApplicationRecord
  belongs_to :assembly
  belongs_to :part
end
 
class Part < ApplicationRecord
  has_many :manifests
  has_many :assemblies, through: :manifests
end

根据经验，如果想把关联模型当做独立实体使用，要用 has_many :through 关联；如果不需要使用关联模型，建立 has_and_belongs_to_many 关联更简单（不过要记得在数据库中创建联结表）。

如果要对联结模型做数据验证、调用回调，或者使用其他属性，要使用 has_many :through 关联
