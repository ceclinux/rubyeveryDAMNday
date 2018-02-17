Rails 哲学包含两大指导思想：

- 不要自我重复（DRY）： DRY 是软件开发中的一个原则，意思是“系统中的每个功能都要具有单一、准确、可信的实现。”。不重复表述同一件事，写出的代码才更易维护、更具扩展性，也更不容易出问题。
- 多约定，少配置： Rails 为 Web 应用的大多数需求都提供了最好的解决方法，并且默认使用这些约定，而不是在长长的配置文件中设置每个细节。


Rails 路由能够识别 URL 地址，并把它们分派给控制器动作或 Rack 应用进行处理。它还能生成路径和 URL 地址，从而避免在视图中硬编码字符串。

在 Blog 应用中创建一个资源（resource）。资源是一个术语，表示一系列类似对象的集合，如文章、人或动物。资源中的项目可以被创建、读取、更新和删除，这些操作简称 CRUD（Create, Read, Update, Delete）。

`root 'welcome#index'` 告诉 Rails 动作 对根路径的访问请求应该发往 welcome 控制器的 index

当我们在浏览器中请求页面时，request.formats 的值是 text/html，因此 Rails 会查找 HTML 模板。request.variant 指明伺服的是何种物理设备，帮助 Rails 判断该使用哪个模板渲染响应。它的值是空的，因为没有为其提供信息。

`articles_path` 辅助方法告诉 Rails 把表单指向和 articles 前缀相关联的 URI 模式。默认情况下，表单会向这个路由发起 POST 请求。这个路由和当前控制器 ArticlesController 的 create 动作相关联。

在 Rails 中，模型使用单数名称，对应的数据库表使用复数名称

在 change 方法中定义的操作都是可逆的

而在 Ruby 中类名必须以大写字母开头。

Rails 提供了多种安全特性来帮助我们编写安全的应用，上面看到的就是一种安全特性。这个安全特性叫做 健壮参数（strong parameter），要求我们明确地告诉 Rails 哪些参数允许在控制器动作中使用。

为什么我们要这样自找麻烦呢？一次性获取所有控制器参数并自动赋值给模型显然更简单，但这样做会造成恶意使用的风险。设想一下，如果有人对服务器发起了一个精心设计的请求，看起来就像提交了一篇新文章，但同时包含了能够破坏应用完整性的额外字段和值，会怎么样？这些恶意数据会批量赋值给模型，然后和正常数据一起进入数据库，这样就有可能破坏我们的应用或者造成更大损失。

注意在 create 动作中，当 save 返回 false 时，我们用 render 代替了 redirect_to。使用 render 方法是为了把 @article 对象回传给 new 模板。这里渲染操作是在提交表单的这个请求中完成的，而 redirect_to 会告诉浏览器发起另一个请求。

在 ArticlesCo ntroller 中添加 @article = Article.new 是因为如果不这样做，在视图中 @article 的值就会是 nil，这样在调用 @article.errors.any? 时就会抛出错误。

```ruby
class Article < ApplicationRecord
end
```

虽然这个文件中的代码很少，但请注意`Article`类继承自`ApplicationRecord`类，而`ApplicationRecord`类继承自`ActiveRecord::Base`类。正是`ActiveRecord::Base`类为`Rails`模型提供了大量功能，包括基本的`CRUD`操作、数据验证，以及对复杂搜索的支持和关联多个模型的能力

在上面的代码中，link_to 辅助方法生成“Destroy”链接的用法有点不同，其中第二个参数是具名路由（named route），还有一些选项作为其他参数。method: :delete 和 data: { confirm: 'Are you sure?' } 选项用于设置链接的 HTML5 属性，这样点击链接后 Rails 会先向用户显示一个确认对话框，然后用 delete 方法发起请求。这些操作是通过 JavaScript 脚本 rails-ujs 实现的，这个脚本在生成应用骨架时已经被自动包含在了应用的布局中（app/views/layouts/application.html.erb）。如果没有这个脚本，确认对话框就无法显示。

```
bin/rails generate model Comment commenter:string body:text article:references
```

上面的代码在 articles 资源中创建 comments 资源，这种方式被称为嵌套资源。这是表明文章和评论之间层级关系的另一种方式。

Active Record 模式出自 Martin Fowler 写的《企业应用架构模式》一书。在 Active Record 模式中，对象中既有持久存储的数据，也有针对数据的操作。Active Record 模式把数据存取逻辑作为对象的一部分，处理对象的用户知道如何把数据写入数据库，还知道如何从数据库中读出数据。


Single table inheritance

Active Record allows inheritance by storing the name of the class in a column that by default is named “type” (can be changed by overwriting Base.inheritance_column). This means that an inheritance looking like this:

class Company < ActiveRecord::Base; end
class Firm < Company; end
class Client < Company; end
class PriorityClient < Client; end

When you do Firm.create(name: "37signals"), this record will be saved in the companies table with type = “Firm”. You can then fetch this row again using Company.where(name: '37signals').first and it will return a Firm object.

Be aware that because the type column is an attribute on the record every new subclass will instantly be marked as dirty and the type column will be included in the list of changed attributes on the record. This is different from non Single Table Inheritance(STI) classes:
```ruby
Company.new.changed? # => false
Firm.new.changed?    # => true
Firm.new.changes     # => {"type"=>["","Firm"]}
```
If you don't have a type column defined in your table, single-table inheritance won't be triggered. In that case, it'll work just like normal subclasses with no special magic for differentiating between them or reloading the right type with find.

Note, all the attributes for all the cases are kept in the same table. Read more: www.martinfowler.com/eaaCatalog/singleTableInheritance.html



