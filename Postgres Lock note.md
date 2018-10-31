## For update

`For update` causes the rows retrieved by the `SELECT` statement to be locked as though for update.This prevents them from being locked, modified or deleted by other transactions until the current transaction ends. That is, other transaction that attempts `UPDATE, DELETE, SELECT FOR UPDATE, SELECT FOR NO KEY UPDATE, SELECT FOR SHARE or SELECT FOR KEY SHARE` of there rowswill be blocked until the current transaction ends; conversely, `SELECT FOR UPDATE` will wait for a concurrent transaction that has run any of those commands on the same row, and will then lock and return the updated row.

For example, when you run ALTER TABLE items ADD COLUMN last_update timestamptz, the command will first block until all queries on the items table have finished, and other queries on the table will block until the ALTER TABLE is done.

```sql
CREATE TABLE items (
  key text primary key,
  value jsonb
);

BEGIN;
ALTER TABLE items ADD COLUMN last_update timestamptz;
```

Now open another terminal and in psql, run:

```sql
SELECT * FROM items;
< nothing happens (waiting for a lock) >
```

If you go back to the first session and run `COMMIT`, you'll see that the second session finishes immediately afterwards. Locks are always kept until commit or rollback.

One other thing to be aware of is that Postgres uses lock queues. If you run an `ALTER TABLE` command then that command goes into queue and blocks unitl all queries on that table are finished, but andy `SELECT` that comes immediately after will be blocked until the `ALTER TABLE` is finished even if the `ALTER TABLE`is not yet running.

 An exclusive lock prevents any other locker from obtaining any sort of a lock on the object. This provides isolation by ensuring that no other locker can observe or modify an exclusively locked object until the locker is done writing to that object.

Non-exclusive locks are granted for read-only access. For this reason, non-exclusive locks are also sometimes called read locks. Since multiple lockers can simultaneously hold read locks on the same object, read locks are also sometimes called shared locks.

A non-exclusive lock prevents any other locker from modifying the locked object while the locker is still reading the object. This is how transactional cursors are able to achieve repeatable reads; by default, the cursor's transaction holds a read lock on any object that the cursor has examined until such a time as the transaction is committed or aborted. 

When one thread of control wants to obtain access to an object, it requests a lock for that object, this provide your application with its transactional isolation gurantees by ensuring that:

1. No other thread of control can read the object(in the case of exclusive lock), and
2. No other thread of control can modify the object(in the case of an exclusive or non-exclusive lock).

## Blocks

Simply put, a thread of control is blocked when it attempts to obtain a lock, but that attempt is denied because some other thread of control holds a conflicting lock. Once blocked, the thread of control is temporarily unable to make any forward progres until the requested lock is obtained or the operation requesting the lock is abandoned.

## Deadlock

A deadlock occurs when two or more threads of control are blocked, each waiting on a resource held by the other thread. When this happends, there is **no possibility** of the threads ever making forward progress unless some outside agent take action to break the deadlock.
