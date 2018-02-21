## Action Controller概览

因此，控制器可以视作模型和视图的中间人，让模型中的数据可以在视图中使用，把数据显示给用户，再把
用户提交的数据保存或更新到模型中。

12.3 方法和动作
一个控制器是一个 Ruby 类，继承自ApplicationController，和其他类一样，定义了很多方法。应用接到请
求时，路由决定运行哪个控制器和哪个动作，然后 Rails 创建该控制器的实例，运行与动作同名的方法。
```ruby
class ClientsController < ApplicationController
def new
end
end
```
例如，用户访问/clients/new 添加新客户，Rails 会创建一个ClientsController 实例，然后调用new 方法。
注意，在上面这段代码中，即使new 方法是空的也没关系，因为 Rails 默认会渲染new.html.erb 视图，除非
动作指定做其他操作。

在控制器的动作中，往往需要获取用户发送的数据或其他参数。在 Web 应用中参数分为两类。第一类随
URL 发送，叫做“查询字符串参数”，即 URL 中? 符号后面的部分。第二类经常称为“POST 数据”，一般来自
用户填写的表单。之所以叫做“POST 数据”，是因为这类数据只能随 HTTP POST 请求发送。Rails 不区分这
两种参数，在控制器中都可通过params 散列获取：


注意，参数的值始终是字符串，Rails 不会尝试转换类型。

默认情况下，基于安全考虑，参数中的[nil] 和[nil, nil, …] 会替换成[]。

params 散列始终有:controller 和:action 两个键，但获取这两个值应该使用controller_name 和action_
name 方法。路由中定义的参数，例如:id，也可通过params 散列获取。例如，假设有个客户列表，可
以列出激活和未激活的客户。我们可以定义一个路由，捕获下面这个 URL 中的:status 参数：
get '/clients/:status' => 'clients#index', foo: 'bar'
此时，用户访问/clients/active 时，params[:status] 的值是"active"。同时，params[:foo] 的值会被设
为"bar"，就像通过查询字符串传入的一样。控制器还会收到params[:action]，其值为"index"，以及
params[:controller]，其值为"clients"。

如果在初始化脚本中开启了config.wrap_parameters 选项，或者在控制器中调用了wrap_parameters 方法，
可以放心地省去 JSON 参数中的根元素。此时，Rails 会以控制器名新建一个键，复制参数，将其存入这个键
名下。因此，上面的参数可以写成：
```
{ "name": "acme", "address": "123 Carrot Street" }
```
假设把上述数据发给CompaniesController，那么参数会存入:company 键名下：
```
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: 
"123 Carrot
Street" } }
```

params 散列始终有:controller 和:action 两个键，但获取这两个值应该使用controller_name 和action_
name 方法。路由中定义的参数，例如:id，也可通过params 散列获取。例如，假设有个客户列表，可
以列出激活和未激活的客户。我们可以定义一个路由，捕获下面这个 URL 中的:status 参数：
get '/clients/:status' => 'clients#index', foo: 'bar'
此时，用户访问/clients/active 时，params[:status] 的值是"active"。同时，params[:foo] 的值会被设
为"bar"，就像通过查询字符串传入的一样。控制器还会收到params[:action]，其值为"index"，以及
params[:controller]，其值为"clients"。

params.permit(:id)
若params 中有:id 键，且:id 是标量值，就可以通过白名单检查；否则:id 会被过滤掉。因此，不能传入数
组、散列或其他对象。
允许使用的标量类型有：String、Symbol、NilClass、Numeric、TrueClass、FalseClass、Date、Time、
DateTime、StringIO、IO、ActionDispatch::Http::UploadedFile 
和Rack::Test::UploadedFile。

若想指定params 中的值必须为标量数组，可以把键对应的值设为空数组：
params.permit(id: [])
有时无法或不便声明散列参数或其内部结构的有效键，此时可以映射为一个空散列：
params.permit(preferences: {})
但是要注意，这样就能接受任何输入了。此时，permit 确保返回的结构中只有允许的标量，其他值都会过滤
掉。
若想允许传入整个参数散列，可以使用permit! 方法：
```
params.require(:log_entry).permit!
```
此时，允许传入整个:log_entry 散列及嵌套散列，不再检查是不是允许的标量值。使用permit! 时要特别注
意，因为这么做模型中所有现有的属性及后续添加的属性都允许进行批量赋值。
