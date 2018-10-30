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
