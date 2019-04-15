## Why Put idempotent

Put is considered idempotent. When you PUT a resource, these two assumption are in play:

1. You are referring to an entity, not to a collection
2. The entity you are supplying is complete(the entire entity)

If you POST this document to `/users`, as you suggest, then you might get back an entity such as

```
## /users/1

{
    "username": "skwee357",
    "email": "skwee357@domain.com"
}
```

If you want to modify this entity later, you choose between PUT and PATCH. A PUT might look like this:

```
PUT /users/1
{
    "username": "skwee357",
    "email": "skwee357@gmail.com"       // new email address
}
```

You can accomplish the same using `PATCH`. That might look like this:

```
PATCH /users/1
{
    "email": "skwee357@gmail.com"       // new email address
}
```

You'll notice a difference right away between these two. The PUT included all of the parameters on this user, but PATCH only included the one that was being modified(`email`)

When using `PUT`，it is assumed that you are sending the complete entity, and that complete entity `replaces` any existing entity at that URI. In the above example, the `PUT` and `PATCH` accomplish the same goal: they both change this user's email address. ut PUT handles it by replacing the entire entity, while PATCH only 
updates the fields that were supplied, leaving the others alone.

Since PUT requests include the entire entity, if you issue the same request repeatedly, it should always have the same outcome(the data you sent is now the entire data of the entity). Therefore PUT is idempotent.

![](https://pic1.zhimg.com/v2-4fe2dee7f91519e25c43f5c629c6d36c_b.jpg)

Level0和Level1最大的区别是，就是Level1拥有了Restful的第一个特征-- 面向资源，这对构建可伸缩、分布式的架构是至关重要的。同时，如果把Level0的数据格式转换成XML，那么其实就是SOAP，SOAP的特点是关注行为和处理，和面向资源的RESTful有很大不同。

Level2，真正将HTTP作为了一种传输协议，最直观的一点就是Level2使用了**HTTP动词**，GET/PUT/POST/DELETE/PATCH....,这些都是HTTP的规范，规范的作用自然是重大的，用户看到一个POST请求，就知道它不是**幂等**的，使用时要小心，看到PUT，就知道他是幂等的，调用多几次都不会造成问题，当然，这些的前提都是API的设计者和开发者也遵循这一套规范，确保自己提供的PUT接口是幂等的。

Level3，关于这一层，有一个古怪的名词，叫[HATEOAS](https://link.zhihu.com/?target=https%3A//en.wikipedia.org/wiki/HATEOAS)（Hypertext As The Engine Of Application State），中文翻译为“将超媒体格式作为应用状态的引擎”，核心思想就是每个资源都有它的状态，不同状态下，可对它进行的操作不一样。理解了这一层，再来看看REST的全称，Representational State Transfer，中文翻译为“表述性状态转移”，是不是好理解多了？

Level3的Restful API，给使用者带来了很大的便利，**使用者只需要知道如何获取资源的入口，之后需的每个URL都可以通过请求获得，无法获得就说明无法执行那个请求**。

现在，我们还是发出请求，请求内容和上一次一样

```
POST /orders

{
    "orderName": "latte"
}
```

```
{
    "orderId": "123456",
    "link": {
        "rel": "cancel",
        "url": "/order/123456"
    }
}
```

