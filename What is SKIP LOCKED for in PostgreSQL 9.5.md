The main utility of SKIP LOCKED is for building simple, reliable and efficient concurrent work queues.

##Most work queue implementations in SQL are wrong


- It fails to consider that statements don’t execute atomically, tries to use subqueries and/or writeable CTEs as if the whole statement is a single atomic unit, and as a result hands out the same work queue entry to multiple workers when run concurrently;
-It marks a job as done as soon as it hands it out and no recovery mechanism for if a worker takes a job then fails, so the job is just lost; or
    It thinks it’s handing jobs out concurrently, but in practice all but one worker are blocked on a row lock so all workers take turns getting jobs.

The few exceptions I’ve seen generally use PostgreSQL’s advisory locking features or use various time-and-expiry based methods of queue cleanup and recovery. Including the popular off-the-shelf ones that are known to work well. They do, just at a performance cost.

## “Find me the next unclaimed row” shouldn’t be hard, though, surely?

“How do I find the first row (by some given ordering) in a queue table that nobody else has claimed and claim it for myself? It needs to automatically revert to being unclaimed again if I crash or exit for any reason. Many other workers will be doing the same thing at the same time. It is vital that each item get processed exactly once; none may be skipped and none may be processed more than once.”

This is harder than you’d think because SQL statements do not execute atomically. A subquery might run before the outer query, depending on how the planner/optimizer does things. Many of the race conditions that can affect series of statements can also affect single statements with CTEs and subqueries, but the window in which they occur is narrower because the statement-parts usually run closer together. So lots of code that looks right proves not to be, it’s just right 99.95% of the time, or it’s always right until that day your business gets a big surge of business and concurrency goes up. Sometimes that’s good enough. Often it isn’t.

Additionally, PostgreSQL uses MVCC with snapshots to control row visibility. The main consequence is that you can't see a row another transaction inserted until it commits. Even then PostgreSQL lets that row "appear" to existing transactions at certain limited points, including the start of a new statement. PostgresSQL makes a few exceptions to this rule, most notably with UNIQUE indexes, but in general you can't see uncommitted rows.

That means that tricks like:

```sql
UPDATE queue
SET is_done = 't'
WHERE itemno = (
  SELECT itemno
  FROM queue
  WHERE NOT is_done
  ORDER BY itemno
  FOR UPDATE
  LIMIT 1
)
RETURNING itemno
```

If two are started at exactly the same moment, the subSELECTs for each will be processed first(It's not that simple, but we can pretend for this purpose. Don't reply on subqueries executing in any particular order for correctness). Each one scans for a row with `is_done = 'f'`. Both find the same row and attempt to lock it. One succeeds, one waits on the other one's lock. Whoops, your "concurrent" queue is serialized. If the first xact to get the lock rolls back the second get the row and tries the same row.
