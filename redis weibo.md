一个人关注的人的时间线是存在zset上，键名`home_timeline:#{uid}`，而这个zset的member和score分别存的是微博id和时间。

一个人的自己的时间线是存在zset上，键名`self_timeline:#{uid}`，而这个zset的member和score分别存的是微博id和时间。

具体的消息存在hash上，hash的键名是`weibo: #{weibo_id}`，hash里面的key有content, id, uid, created_at

被关注的关系存在set上，set的键名是`following: #{uid}`，里面的元素是uid1，uid2，uid3，表示这些uids都是关注uid的

假设存在一个时间线的最大长度，为`TIMELINE_SIZE`

以下仅描述在redis里面的操作

创建微博代码如下
```ruby
def create_weibo(uid, weibo)
  redis.hmset("weibo: #{weibo.id}", {"content": weibo.content, "id": weibo.id, "uid":weibo.creator_id, "created_at": weibo.created_at})
  redis.zadd("self_timeline:#{f}",  weibo.created_at, weibo.id)
  redis.zremrangebyrank("self_timeline:#{f}", 0, -TIMELINE_SIZE - 1)
  followers  = redis.smembers("followers:#{uid}")
  followers.each do |f|
    redis.zadd("home_timeline:#{f}",  weibo.created_at, weibo.id)
    redis.zremrangebyrank("home_timeline:#{f}", 0, -TIMELINE_SIZE - 1)
  end
end
```

删除微博代码如下
```ruby
def destroy_weibo(uid, weibo_id)
  redis.del(weibo_id)
  redis.zrem("self_timeline:#{uid}",  weibo_id)
  followers = redis.smembers("followers:#{uid}")
  followers.each do |f|
    redis.zrem("home_timeline:#{f}",  weibo_id)
  end
end
```

关注用户的代码如下
```ruby
def follow_user(uid, followed_uid)
  return if redis.sismember "followers:#{followed_uid}", uid
  redis.sadd "followers:#{followed_uid}", uid
  weibo_ids_and_time = redis.zrange("self_timeline:#{followed_uid}", 0, -TIMELINE_SIZE - 1, withscores= True)
  redis.zadd("home_timeline:#{followed_uid}", weibo_ids_and_time)
  redis.zremrangebyrank("home_timeline:#{f}", 0, -TIMELINE_SIZE - 1)
end
```

取消关注用户的代码如下
```ruby
def unfollow_user(uid, followed_uid)
  return unless redis.sismember "followers:#{followed_uid}", uid
  redis.srem "followers:#{followed_uid}", uid
  weibo_ids_and_time = redis.zrange("self_timeline:#{followed_uid}", 0, -TIMELINE_SIZE - 1, withscores= True)
  redis.zrem("home_timeline:#{followed_uid}", weibo_ids_and_time)
end
```
