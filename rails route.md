在创建资源路由时，会同时创建多个可以在控制器中使用的辅助方法。例如，在创建 resources :photos 路由时，会同时创建下面的辅助方法：
```
    photos_path 辅助方法，返回值为 /photos
    new_photo_path 辅助方法，返回值为 /photos/new
    edit_photo_path(:id) 辅助方法，返回值为 /photos/:id/edit（例如，edit_photo_path(10) 的返回值为 /photos/10/edit）
    photo_path(:id) 辅助方法，返回值为 /photos/:id（例如，photo_path(10) 的返回值为 /photos/10）
```
这些辅助方法都有对应的 _url 形式（例如 photos_url）。前者的返回值是路径，后者的返回值是路径加上由当前的主机名、端口和路径前缀组成的前缀。

如前文所述，避免深层嵌套（deep nesting）的方法之一，是把动作集合放在在父资源中，这样既可以表明层级关系，又不必嵌套成员动作。换句话说，只用最少的信息创建路由，同样可以唯一地标识资源，例如：
```
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```
这种方式在描述性路由（descriptive route）和深层嵌套之间取得了平衡。上面的代码还有简易写法，即使用 :shallow 选项：
resources :articles do
  resources :comments, shallow: true
end

```
添加集合路由的方式如下：
resources :photos do
  collection do
    get 'search'
  end
end

通过上述声明，Rails 路由能够识别 /photos/search 路径上的 GET 请求，并把请求映射到 Photos 控制器的 search 动作上，同时创建 search_photos_url 和 search_photos_path 辅助方法。

和成员路由一样，我们可以使用集合路由的 :on 选项：
resources :photos do
  get 'search', on: :collection
end
```

To add a route to the collection:
```
resources :photos do
  collection do
    get 'search'
  end
end
```
This will enable Rails to recognize paths such as /photos/search with GET, and route to the search action of PhotosController. It will also create the search_photos_url and search_photos_path route helpers.

Just as with member routes, you can pass :on to a route:
```
resources :photos do
  get 'search', on: :collection
end
```

This will enable Rails to recognize paths such as /comments/new/preview with GET, and route to the preview action of CommentsController. It will also create the preview_new_comment_url and preview_new_comment_path route helpers.
```
resources :comments do
  get 'preview', on: :new
end
```
