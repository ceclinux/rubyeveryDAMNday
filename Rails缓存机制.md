# Rails 缓存概览

页面缓存时 Rails 提供的一种缓存机制，让 Web 服务器（如 Apache 和 NGINX）直接伺服生成的页面，而不经由 Rails 栈处理。虽然这种缓存的速度超快，但是不适用于所有情况（例如需要验证身份的页面）。此外，因为 Web 服务器直接从文件系统中伺服文件，所以你要自行实现缓存失效机制。

动态 Web 应用一般使用不同的组件构建页面，不是所有组件都能使用同一种缓存机制。如果页面的不同部分需要使用不同的缓存机制，在不同的条件下失效，可以使用片段缓存。

片段缓存把视图逻辑的一部分放在 cache 块中，下次请求使用缓存存储器中的副本伺服。

例如，如果想缓存页面中的各个商品，可以使用下述代码：

<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
首次访问这个页面时，Rails 会创建一个具有唯一键的缓存条目。缓存键类似下面这种：

views/products/1-201505056193031061005000/bea67108094918eeba42cd4a6e786901
中间的数字是 product_id 加上商品记录的 updated_at 属性中存储的时间戳。Rails 使用时间戳确保不伺服过期的数据。如果 updated_at 的值变了，Rails 会生成一个新键，然后在那个键上写入一个新缓存，旧键上的旧缓存不再使用。这叫基于键的失效方式。

视图片段有变化时（例如视图的 HTML 有变），缓存的片段也失效。缓存键末尾那个字符串是模板树摘要，是基于缓存的视图片段的内容计算的 MD5 哈希值。如果视图片段有变化，MD5 哈希值就变了，因此现有文件失效。

有时，可能想把缓存的片段嵌套在其他缓存的片段里。这叫俄罗斯套娃缓存（Russian doll caching）。

俄罗斯套娃缓存的优点是，更新单个商品后，重新生成外层片段时，其他内存片段可以复用。

前一节说过，如果缓存的文件对应的记录的 updated_at 属性值变了，缓存的文件失效。但是，内层嵌套的片段不失效。

对下面的视图来说：

<% cache product do %>
  <%= render product.games %>
<% end %>
而它渲染这个视图：

<% cache game do %>
  <%= render game %>
<% end %>
如果游戏的任何一个属性变了，updated_at 的值会设为当前时间，因此缓存失效。然而，商品对象的  updated_at 属性不变，因此它的缓存不失效，从而导致应用伺服过期的数据。为了解决这个问题，可以使用 touch 方法把模型绑在一起：

class Product < ApplicationRecord
  has_many :games
end
 
class Game < ApplicationRecord
  belongs_to :product, touch: true
end
把 touch 设为 true 后，导致游戏的 updated_at 变化的操作，也会修改关联的商品的 updated_at 属性，从而让缓存失效。

