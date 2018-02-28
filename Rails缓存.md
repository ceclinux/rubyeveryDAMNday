生成 Rails API 应用使用下述命令：

```ruby
$ rails new my_api --api
```
这个命令主要做三件事：

配置应用，使用有限的中间件（比常规应用少）。具体而言，不含默认主要针对浏览器应用的中间件（如提供 cookie 支持的中间件）。
让 ApplicationController 继承 ActionController::API，而不继承 ActionController::Base。与中间件一样，这样做是为了去除主要针对浏览器应用的 Action Controller 模块。
配置生成器，生成资源时不生成视图、辅助方法和静态资源。

Sets the etag and/or last_modified on the response and checks it against the client request. If the request doesn't match the options provided, the request is considered stale and should be generated from scratch. Otherwise, it's fresh and we don't need to generate anything and a reply of 304 Not Modified is sent.

ETag 使用场景举例
这个东西非常适合用于动态内容上面，以减少不必要的 HTML 下载，达到加速的目的。

比如下面这个场景的例子：

用户访问 /topics/11 页面，TopicsController#show 加载 @topic，并通过 View 生成内容返回
用户来回访问 10 次 /topics/11，可此页面内容无任何变化
过了1天以后，@topic 有了新的回复，用户再次访问的时候，内容变了
上面的场景用户一共访问了 12 次 /topics/11 这个页面，但只有第一次和最后一次才有实质性的内容需要下载的，可在没有 ETag 的情况下面，服务器执行和浏览器下载都是有 12 次，其中的 10 次是多余的。

如果加上 ETag 以后，将会是这样：

用户访问 /topics/11 页面，TopicsController#show 加载 @topic，并通过 View 生成内容返回，并给出目前内容的 ETag: 89vbsn28716
用户带着 ETag: 89vbsn28716 再次访问 /topics/11 ，服务器检查 ETag 与执行结果，发现无变化，返回 304，浏览器直接使用 Cache 的内容渲染页面
过了一天以后，@topic 有了新回复，用户再次带着 ETag: 89vbsn28716 /topics/11，服务器检查 ETag 发现不对了，生成新内容，并返回 200
这个过程中，服务端执行了 12 次页面，而下载 HTML 内容到本地却只有两次。

一个客户端经常会访问同一个资源，比如用浏览器访问网站首页或查看同一篇文章，或用app访问同一个api，如果该资源和他之前访问过的没有任何改变，就可以利用http规范中的304 Not Modified 响应头( http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.3.5 )，直接用客户端的缓存，而无需在服务器端再生成一次内容。 在Rails里面内置了fresh_when这个方法，一行代码就可以完成：

class ArticlesController
  def show
    @article = Article.find(params[:id])
    fresh_when :last_modified => @article.updated_at.utc, :etag => @article
  end
end
下次用户再访问的时候，会对比request header里面的If-Modified-Since和If-None-Match，如果相符合，就直接返回304，而不再生成response body。

但是这样会遇到一个问题，假设我们的网站导航有用户信息，一个用户在未登陆专题访问了一下，然后登陆以后再访问，会发现页面上显示的还是未登陆状态。或者在app访问一篇文章，做了一下收藏，下次再进入这篇文章，还是显示未收藏状态。解决这个问题的方法很简单，将用户相关的变量也加入到etag的计算里面：
```ruby
fresh_when :etag => [@article.cache_key, current_user.id]
fresh_when :etag => [@article.cache_key, current_user_favorited]
```

```ruby
# controller
  def index
    @articles = Article.first(10)
  end

# view
- @articles.each do |article|
  h1 = article.name
  span = article.category.name
```

rails内置了query cache （ https://github.com/rails/rails/blob/master/activerecord/lib/active_record/connection_adapters/abstract/query_cache.rb ），在同一个请求周期内，如果没有update/delete/insert的操作，会对相同的sql查询进行缓存，如果文章类别都是相同的话，真正去查询数据库只会有1次。

If-Modified-Since 是一个条件式请求首部，服务器只在所请求的资源在给定的日期时间之后对内容进行过修改的情况下才会将资源返回，状态码为 200  。如果请求的资源从那时起未经修改，那么返回一个不带有消息主体的  304  响应，而在 Last-Modified 首部中会带有上次修改时间。 不同于  If-Unmodified-Since, If-Modified-Since 只可以用在 GET 或 HEAD 请求中。

当与 If-None-Match 一同出现时，它会被忽略掉，除非服务器不支持 If-None-Match。

最常见的应用场景是来更新没有特定 ETag 标签的缓存实体。

在ETag和 If-Match 头部的帮助下，您可以检测到"空中碰撞"的编辑冲突。

例如，当编辑MDN时，当前的wiki内容被散列，并在响应中放入Etag：

ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4
将更改保存到Wiki页面（发布数据）时，POST请求将包含有ETag值的If-Match头来检查是否为最新版本。

If-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"
如果哈希值不匹配，则意味着文档已经被编辑，抛出412前提条件失败错误。

缓存未更改的资源
ETag头的另一个典型用例是缓存未更改的资源。 如果用户再次访问给定的URL（设有ETag字段），显示资源过期了且不可用，客户端就发送值为ETag的If-None -Match header字段：

If-None-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"
服务器将客户端的ETag（作为If-None-Match字段的值一起发送）与其当前版本的资源的ETag进行比较，如果两个值匹配（即资源未更改），服务器将返回不带任何内容的304未修改状态，告诉客户端缓存版本可用（新鲜）。
