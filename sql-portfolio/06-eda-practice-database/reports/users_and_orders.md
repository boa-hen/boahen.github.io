# Report · `users` and `orders`

[← Back to project 06](../README.md)

> **Overview:** The dataset has two linked tables, 6 registered users and 4 orders. The main business question explored is; **Who signed up but never bought anything?**

**Script:** [`EDA practice_users&orders.sql`](../sql/EDA%20practice_users%26orders.sql)

| Table | Columns | Rows |
|---|---|---|
| `users` | `user_id`, `user_name` | 6 (Alice, Bob, Carol, David, Eve, Frank) |
| `orders` | `order_id`, `user_id`, `order_amount`, `order_date` | 4 |

`orders.user_id` points to `users.user_id` (one user can have many orders).

## 1 · Quality checks

| Check | Method | Result |
|---|---|---|
| Duplicate orders | `ROW_NUMBER()` partitioned by user, amount, date (not by `order_id`) | none |
| Duplicate users | `ROW_NUMBER()` partitioned by `user_name` | none |
| NULLs / negative amounts | scan | none |
| **Referential integrity**: orders whose user does not exist | `orders LEFT JOIN users … WHERE users.user_id IS NULL` | **0 rows** |

- The integrity check matters because an "orphan" order (one with no matching user) would silently disappear from any inner join.

## 2 · Who never ordered? (the anti-join)

An **anti-join** keeps rows from one table that have **no match** in another. Take every user, attach their orders if any, then keep those where the order side is empty.

```sql
SELECT u.user_id, u.user_name
FROM users AS u
LEFT JOIN orders AS o ON u.user_id = o.user_id
WHERE o.order_id IS NULL;
```

| user_id | user_name |
|---|---|
| 4 | David |
| 5 | Eve |
| 6 | Frank |

- I found that 3 out of 6 users (50%) never ordered; David, Eve and Frank.

| Metric | Value |
|---|---|
| Total revenue | 425.00 |
| Buyers | 3 (Alice , Bob and Carol) |
| Revenue per buyer (estimate) | 141.67 |


- The total revenue generated from all orders is 425.00, with the exact amount of revenue generated per buyer differing. However, 141.67 is the estimated average revenue amount per buyer.
- There were a total of 4 orders from 3 buyers namely; Alice, Bob and Carol, with Alice ordering twice.
- One nuance to consider is the method of determining the largest customer. Which context should be used as the deciding factor; the person with the most number of orders or the person with the most expensive order? The answer to the question depends on the context selected and this is one difficulty I faced.


## 3 · LEFT JOIN vs RIGHT JOIN

`orders RIGHT JOIN users` returns exactly the same 7 rows as `users LEFT JOIN orders` (6 users, with Alice appearing twice). A `RIGHT JOIN` is a `LEFT JOIN` with the tables swapped, so I prefer the left version because the "main" table is read first.

> [!TIP]
> **Row counts tell a story.** `users LEFT JOIN orders` has **7** rows, more than the 6 users, because Alice has two orders. Joining a "one" table to a "many" table repeats the "one" side. Counting users on that joined result without `DISTINCT` would double-count Alice.
