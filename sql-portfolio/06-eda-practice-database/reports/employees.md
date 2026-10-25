# Report · `employees`

[← Back to project 06](../README.md)

> **Overview:** This is a 15-person company table. It has two missing salaries and three missing managers. I had to decide which of those are *problems* and which are *normal*. Then I asked five questions about pay, hiring, reporting lines and tenure.

**Scripts:** [`EDA practice_employees.sql`](../sql/EDA%20practice_employees.sql) · [`Errors and Corrections for EDA practice_employees.sql`](../sql/Errors%20and%20Corrections%20for%20EDA%20practice_employees.sql)

| Column | Meaning |
|---|---|
| `employee_id` | unique ID |
| `name`, `hire_date` | who was hired and when |
| `salary` | monthly pay (2 values missing) |
| `department_id` | 1, 2 or 3 |
| `manager_id` | the `employee_id` of the person's manager (3 values missing) |

## 1 · Structure and quality checks

| Check | Method | Result |
|---|---|---|
| Duplicate rows | `ROW_NUMBER()` over all non-ID columns | none |
| Text problems | `TRIM` comparisons on `name` | none |
| Missing values in any column | `UNION ALL` of `IS NULL` checks | 5 rows flagged: 2 missing salaries, 3 missing managers |

### Which NULLs are errors?

| NULL | Employees | Verdict | Action |
|---|---|---|---|
| `manager_id` | Noah Brown, Sophia Davis, Mason Moore | **Structural**: They are top of their reporting lines | leave as NULL |
| `salary` | Isabella Wilson (dept 2), Mia White (dept 1) | **Genuinely missing** | estimate, but flag |

I confirmed this by checking who reports to them; each of the three has direct reports (7, 1 and 3 respectively).

### Decision: flag, do not overwrite

The raw `salary` column is untouched. I added two columns in a staging table.

```sql
ALTER TABLE employees_staging ADD COLUMN salary_estimate INT;
ALTER TABLE employees_staging ADD COLUMN salary_is_imputed BOOLEAN DEFAULT FALSE;

UPDATE employees_staging AS emp_table
JOIN (SELECT department_id, ROUND(AVG(salary)) AS dept_avg
      FROM employees_staging GROUP BY department_id) AS dept_avgs
  ON emp_table.department_id = dept_avgs.department_id
SET salary_estimate   = COALESCE(emp_table.salary, dept_avgs.dept_avg),
    salary_is_imputed = emp_table.salary IS NULL;
```

- `COALESCE(salary, dept_avg)` means "use the real salary if there is one but defer to the department average only if the salary is missing".
- Isabella gets **4,933** (department 2's average) and Mia **4,222** (department 1's).
- The department average sits in a **derived table** and is joined in. Putting a subquery on the same table directly inside the `UPDATE` raises MySQL error 1093.
- I verified the raw table still has 2 NULL salaries and that all 13 real salaries were copied unchanged (0 mismatches).

> [!NOTE]
> **A statistical cost I want to be upfront about.** Filling gaps with the *average* leaves the average unchanged, but it makes the data look **less spread out** than it really is, because the filled values sit exactly in the middle. The `salary_is_imputed` flag lets every result say how many values are estimates.

## 2 · Analyses

### Q1 · How does pay vary by department?


| department_id | AVG(salary_estimate) | MIN(salary_estimate) | MAX(salary_estimate) | STDDEV(salary_estimate) |
|---|---|---|---|---|
| 1 | 4221.7143 | 2000 | 7800 | 2020.1868 |
| 2 | 4933.2500 | 4100 | 5500 | 521.2165 |
| 3 | 3450.0000 | 2800 | 4100 | 559.017 |

| Dept | Staff | Average | Min | Max | Std dev |
|---|---|---|---|---|---|
| 1 | 7 | 4,222 | 2,000 | 7,800 | **2,020** |
| 2 | 4 | 4,933 | 4,100 | 5,500 | 521 |
| 3 | 4 | 3,450 | 2,800 | 4,100 | 559 |

- Department 1 has a spread about four times wider than the others. Its average of 4,222 describes almost nobody, this is to say that large variance leads to a misleading average salary. The spread of the salary allocation for Departments 2 and 3 appears more reasonable since there is not too much a gap in both.

### Q2 · Top and bottom earner in each department

I employed two `RANK()` windows (one descending, one ascending) in a CTE, to filter and show the top and bottom rank.


| employee_id | name | department_id | salary_estimate | salary_is_imputed | rank_high | rank_low |
|---|---|---|---|---|---|---|
| 3 | Olivia Smith | 1 | 2000 | 0 | 7 | 1 |
| 6 | Noah Brown | 1 | 7800 | 0 | 1 | 7 |
| 5 | Ava Williams | 2 | 4100 | 0 | 4 | 1 |
| 13 | Amelia Thomas | 2 | 5500 | 0 | 1 | 4 |
| 12 | Ethan Anderson | 3 | 2800 | 0 | 4 | 1 |
| 10 | Mason Moore | 3 | 4100 | 0 | 1 | 4 |

| Dept | Highest | Lowest |
|---|---|---|
| 1 | Noah Brown, 7,800 | Olivia Smith, 2,000 |
| 2 | Amelia Thomas, 5,500 | Ava Williams, 4,100 |
| 3 | Mason Moore, 4,100 | Ethan Anderson, 2,800 |

### Q3 · Hiring trend

| Year | 2015 | 2016 | 2017 | 2018 | 2019 | 2020 | 2021 | 2022 | 2023 | 2024 |
|---|---|---|---|---|---|---|---|---|---|---|
| Hires | 1 | 1 | 1 | 1 | 2 | 2 | 2 | 2 | 2 | 1 |

The headcount grew from 1 to 15 with a steady pace of 1 hire a year until 2018 and 2 a year from 2019 to 2023. *However*, due to the low size of the dataset with 15 people, this is best implied as a description of the company and not the company's hiring strategy.

### Q4 · Reporting structure

A **self join** pairs each employee with their manager (`e1.manager_id = e2.employee_id`). To also count managers with *zero* reports, I flipped it to a `LEFT JOIN` the other way (`e1.employee_id = e2.manager_id`):

```sql
SELECT e1.employee_id, e1.name, COUNT(e2.employee_id) AS direct_reports
FROM employees_staging AS e1
LEFT JOIN employees_staging AS e2 ON e1.employee_id = e2.manager_id
GROUP BY e1.employee_id, e1.name;
```

| Manager | Direct reports |
|---|---|
| Noah Brown | **7** |
| Mason Moore | 3 |
| Sophia Davis | 1 |
| James Miller | 1 |
| everyone else (11 people) | 0 |

**Findings**
- Noah manages across 2 departments; four employees in departmnt 2 as well as three in his own department 1, so his team crosses department lines.
- James Miller reports to Noah *and* manages Olivia, this points to a middle layer in the management pyramid and shows some level of efficiency in handling and supervision.
- Sophia Davis manages 1 person in her department.
- Mason Moore manages 3 employees in his department.

**A question I left open, now answered.** My notes asked *why `COUNT(e2.manager_id)` and `COUNT(e2.employee_id)` give identical results.* Because the join condition is `e1.employee_id = e2.manager_id`, **every matched row has a non-NULL `e2.manager_id` by definition** (it is the very value that matched). Unmatched rows have NULL for *all* `e2` columns. So both counts see exactly the same rows. A column that is **not** part of the join (say `e2.salary`) could differ if it contained NULLs.

### Q5 · Does longer tenure mean higher pay?

I bucketed hire dates with `CASE` per these assignments; *Veteran* (before 2019), *Mid-Tenure* (2019 to 2021), *Recent* (2022 onward).


| AVG(salary_estimate) | num_of_employees | year_tenure |
|---|---|---|
| 3727.1667 | 6 | Mid-Tenure |
| 5900.0000 | 4 | Veteran |
| 3424.4000 | 5 | Recent |

| Tenure | People | Average salary |
|---|---|---|
| Veteran | 4 | 5,900 |
| Mid-Tenure | 6 | 3,727 |
| Recent | 5 | 3,424 |

- Initial analysis shows that company-wide, pay falls as tenure falls. However further analysis after splitting by department shows it is **not consistent**.


| department_id | year_tenure | AVG(salary_estimate) | num_of_employees |
|---|---|---|---|
| 1 | Mid-Tenure | 2676.6667 | 3 |
| 2 | Veteran | 5200.0000 | 1 |
| 2 | Recent | 4100.0000 | 1 |
| 1 | Veteran | 7150.0000 | 2 |
| 1 | Recent | 3611.0000 | 2 |
| 2 | Mid-Tenure | 5216.5000 | 2 |
| 3 | Veteran | 4100.0000 | 1 |
| 3 | Mid-Tenure | 3900.0000 | 1 |
| 3 | Recent | 2900.0000 | 2 |

- In department 1 the Recent group (3,611) earns *more* than Mid-Tenure (2,677), and most cells contain only 1 to 3 people.
**In Conclusion:** The company-wide pattern is partly a *department mix* effect and the sample is too small to separate the two. This is a limitation preventing me from confidently drawing conclusions since the dataset is too small.

### Hypothesis tested and rejected

*"The top earner in a department has no manager."* 
- Initially I assumed the reason for Noah, Sophia and Mason having no managers pointed to them being the top earners of their respective departments. This assumption was mainly favoured after I noticed both Noah and Mason had the highest salaries in their respective departments. I did not confirm the same for Sophia before coming up with this theory.
- Further queries and analysis showed that my theory was false and this was mainly proven with Sophia being a contradiction. Sophia has no manager but is only **second-highest** in department 1, while Amelia being the top earner in department 2 reports to Noah.

## 3 · Mistakes I made and fixed

| Attempt | Problem | Fix |
|---|---|---|
| `ROW_NUMBER() OVER (PARTITION BY YEAR(hire_date))` to count hires per year | gives each person a **position** within the year, not a count | `COUNT(*) OVER (PARTITION BY YEAR(hire_date))` or `GROUP BY` |
| Adding `name` to a `GROUP BY year` query | every row becomes its own group (count = 1) | use the window `COUNT(*) OVER (PARTITION BY …)` to keep extra columns |
| Adding `YEAR(hire_date)` next to the tenure bucket | the output has one row per *year*, not per bucket | group by the bucket only |

More detail in [`docs/debugging-log.md`](../../docs/debugging-log.md).
