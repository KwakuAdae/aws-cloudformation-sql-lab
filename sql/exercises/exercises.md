# SQL Exercises

Try each one yourself before looking at [`../solutions/solutions.sql`](../solutions/solutions.sql).
Run your answers with `./scripts/run-sql.sh -q "..."`, in the console Query Editor, or locally.
Expected answers below come from a freshly seeded database (run `01-schema.sql` and
`02-seed-data.sql`, but not lesson 6, which changes the data).

| # | Level | Question | Expected answer |
|---|-------|----------|-----------------|
| 1 | ⭐ | List all products in the **Sports** category (`category_id = 4`), cheapest first. | 3 rows, starting with *Water Bottle* |
| 2 | ⭐ | How many customers signed up in **2025-Q2** (April–June)? | 4 |
| 3 | ⭐ | Which products are **out of stock**? | *Bluetooth Speaker*, *Rain Jacket* |
| 4 | ⭐⭐ | Show each **country** with its number of customers, only countries with more than one. | Ghana 3, United States 2 |
| 5 | ⭐⭐ | What is the **total revenue of delivered orders**? | 1357.79 |
| 6 | ⭐⭐ | List every **order with its total**, biggest first. Show order id, customer name and total. | Order 12 (Emma Brown, 288.99) is first |
| 7 | ⭐⭐ | Which **customer has placed the most orders**, and how many? | Ama Mensah, 4 |
| 8 | ⭐⭐⭐ | For each **category**, show the number of distinct customers who bought from it (ignore cancelled orders). | Books 4, Clothing 4, Electronics 6, Home 4, Sports 3 |
| 9 | ⭐⭐⭐ | Find customers whose **first order** was in **2025-Q1** (January–March). | Ama Mensah, Kofi Boateng |
| 10 | ⭐⭐⭐ | For each customer, show their **largest single order total** and the date of that order (window function). | 9 rows (Yaw Asante has no orders) |
