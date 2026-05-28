WINDOW FRAME TYPES: ROWS VS. RANGE VS. GROUPS
When an ORDER BY clause is added inside OVER(), SQL automatically applies a default hidden frame boundary: RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW. To look beyond this restriction or capture accurate intervals, you must explicitly declare your frame type.

1. ROWS
Definition: Counts a physical number of lines backward or forward relative to the current line position.

Behavior: Strict line offset count. It does not check if data values are missing, skipped, or duplicated.

Best Used For: Sequential ledger rows, contiguous log files, or data without matching timestamps.

2. RANGE
Definition: Looks at the actual data values inside the ORDER BY column and calculates an exact logical offset threshold.

Behavior: Dynamic frame size. If a window looks back INTERVAL 7 DAY, it filters for rows where the actual date value drops within that mathematical range, skipping any chronological gaps in the table. If rows share identical values, they are processed simultaneously as one single frame.

Best Used For: Time-series calculations with missing calendar dates or irregular numeric intervals.

3. GROUPS
Definition: Counts steps back or forward across sets of identical values (peer groups) rather than lines or intervals.

Behavior: Treats duplicate values as a single tied unit. A lookback of 2 PRECEDING means "look back across 2 value changes," bringing in every matching row within those prior value changes.

Best Used For: Aggregating human behaviors or transactions that naturally cluster under the same timestamp or category key.

HANDLING NULLS AND SORTING
Ordering Nulls: By default, BigQuery, PostgreSQL, and Oracle treat NULL as the largest possible value (sorting to the bottom on ASC). SQL Server and MySQL treat it as the smallest value (sorting to the top on ASC). Use NULLS FIRST or NULLS LAST to explicitly dictate this behavior.

Value Filtering: Value-navigation functions (FIRST_VALUE, LAST_VALUE, LAG, LEAD) default to RESPECT NULLS. If they hit an empty cell, they output NULL. Specifying IGNORE NULLS bypasses empty cells entirely, continuing down the frame partition until a populated data point is discovered.

RANKING
ROW_NUMBER
SELECT
date,
sleep_stage_rank,
duration_hours,
row_number() over (partition by date order by duration_hours desc) as row_num
FROM my-data-479716.mysql_health_stats.view_sleep_summary

group by 1,2,3
order by date, row_num
LIMIT 1000

;

SELECT

conditions,
sleep_stage_rank,
round(sum(duration_hours),0) as sleep_time,
row_number() over (partition by conditions order by sum(duration_hours) desc) as stage_rank
FROM my-data-479716.mysql_health_stats.view_sleep_summary

group by 1,2
order by conditions

;

RANK
select
rank() over (order by total_steps desc) as steps_rank,
date,
total_steps
FROM my-data-479716.mysql_health_stats.view_summary

;

DENSE_RANK
select
dense_rank() over (order by total_steps desc) as steps_dense_rank,
date,
total_steps
FROM my-data-479716.mysql_health_stats.view_summary

order by steps_dense_rank

;

VALUE
LAG
SELECT
date,
lag(total_steps,1) over(order by date) as prev_day_steps,
total_steps
FROM my-data-479716.mysql_health_stats.view_summary

order by date
LIMIT 1000

;

LEAD
SELECT
date,
total_steps,
lead(total_steps,1) over(order by date) as next_day_steps,
FROM my-data-479716.mysql_health_stats.view_summary

order by date
LIMIT 1000

;

FIRST_VALUE
SELECT
user_id,
event_name,
-- Finds the first non-null event in the session
FIRST_VALUE(event_name IGNORE NULLS) OVER(
PARTITION BY user_id ORDER BY timestamp
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
) AS first_interaction
FROM project.dataset.user_events

;

LAST_VALUE
SELECT
user_id,
event_name,
-- Finds the last non-null event in the session
LAST_VALUE(event_name IGNORE NULLS) OVER(
PARTITION BY user_id ORDER BY timestamp
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
) AS last_interaction
FROM project.dataset.user_events

;

DISTRIBUTION
NTILE
select
stage,
date,
sum(cast(duration_hours as decimal)) as time_asleep,
ntile(4) over (partition by date order by sum(cast(duration_hours as decimal))) as time_quartile

from my-data-479716.mysql_health_stats.sleep_summary

group by 1,2

;

PERCENT_RANK
SELECT
test_score,
-- Calculates percentile.
-- NULLS LAST ensures missing scores don't get the highest rank.
PERCENT_RANK() OVER(ORDER BY test_score ASC NULLS LAST) AS percentile
FROM project.dataset.student_scores

;

AGGREGATES
SUM
sum with partitioned totals
SELECT
date,
sleep_stage_rank,
sum(duration_hours) as duration_hours,
sum(sum(duration_hours)) over(partition by date) as total_duration_hours
FROM my-data-479716.mysql_health_stats.view_sleep_summary

group by
date,
sleep_stage_rank

LIMIT 1000

;

AVG
running avg with rows
select
date,
sum(cast(duration_hours as decimal)) as total_sleep,
avg(sum(cast(duration_hours as decimal))) over (order by date rows between 6 preceding and current row) as seven_day_avg_sleep

from my-data-479716.mysql_health_stats.sleep_summary

group by 1
order by 1

;

running avg with range
select
date,
sum(cast(duration_hours as decimal)) as total_sleep,
-- Evaluates the actual date values to sum across a 7-day logical calendar range
sum(sum(cast(duration_hours as decimal))) over (order by date range between interval 7 day preceding and current row) as rolling_seven_calendar_day_sleep

from my-data-479716.mysql_health_stats.sleep_summary

group by 1
order by 1

;

running avg with groups
select
date,
stage,
sum(cast(duration_hours as decimal)) as stage_sleep,
-- Treats duplicate identical dates as single group units, looking back across 2 unique date changes
sum(sum(cast(duration_hours as decimal))) over (order by date groups between 2 preceding and current row) as rolling_three_distinct_dates_sleep

from my-data-479716.mysql_health_stats.sleep_summary

group by 1,2
order by 1

;

MIN
select
min(total_steps) as minimum_steps
FROM my-data-479716.mysql_health_stats.view_summary

;

MAX
select
max(total_steps) as maximum_steps
FROM my-data-479716.mysql_health_stats.view_summary

;