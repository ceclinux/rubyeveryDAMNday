When increasing concurrency by using a multi-threaded web server like Puma, or multi-process web server like Unicorn, you must be aware of the number of connections your app holds to the database and how many connections the database can accept. Each thread or process requires a different connection to the database. To accommodate this, Active Record provides a connection pool that can hold several connections at a time.

# Connection pool
By default Rails (Active Record) will only create a connection when a new thread or process attempts to talk to the database through a SQL query. Active Record limits the total number of connections per application through a database setting pool; this is the maximum size of the connections your app can have to the database. The default maximum size of the database connection pool is 5. If you try to use more connections than are available, Active Record will block and wait for a connection from the pool. When it cannot get a connection, a timeout error will be thrown. It may look something like this:

```
ActiveRecord::ConnectionTimeoutError - could not obtain a database connection within 5 seconds. The max pool size is currently 5; consider increasing it
```
