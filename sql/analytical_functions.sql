Ranking
ROW_NUMBER

SELECT 
date,
sleep_stage_rank,
duration_hours,
row_number() over (partition by date order by duration_hours desc) as row_num
FROM `my-data-479716.mysql_health_stats.view_sleep_summary`

 
group by 1,2,3
 order by date, row_num
 LIMIT 1000

;

SELECT  
conditions,
sleep_stage_rank,
round(sum(duration_hours),0) as sleep_time,
row_number() over (partition by conditions order by sum(duration_hours) desc) as stage_rank
FROM `my-data-479716.mysql_health_stats.view_sleep_summary`

group by 1,2
order by conditions

;

RANK

select
rank() over (order by total_steps desc) as steps_rank,
 date,
total_steps
  FROM `my-data-479716.mysql_health_stats.view_summary`


DENSE_RANK

select
dense_rank() over (order by total_steps desc) as steps_dense_rank,
 date,
total_steps
  FROM `my-data-479716.mysql_health_stats.view_summary`

  order by steps_dense_rank

Value

LAG

SELECT
date,
lag(total_steps,1) over(order by date) as prev_day_steps,
total_steps
 FROM `my-data-479716.mysql_health_stats.view_summary`

 order by date
 LIMIT 1000

LEAD

SELECT
date,
total_steps,
lead(total_steps,1) over(order by date) as next_day_steps,
 FROM `my-data-479716.mysql_health_stats.view_summary`

 order by date
 LIMIT 1000

FIRST_VALUE

SELECT 
  user_id,
  event_name,
  -- Finds the first non-null event in the session
  FIRST_VALUE(event_name IGNORE NULLS) OVER(
    PARTITION BY user_id ORDER BY timestamp
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS first_interaction
FROM `project.dataset.user_events`

LAST_VALUE


Distribution
NTILE

select 

stage,
date,
sum(cast(duration_hours as decimal)) as time_asleep,
ntile(4) over (partition by date order by sum(cast(duration_hours as decimal))) as time_quartile

from `my-data-479716.mysql_health_stats.sleep_summary`

group by 1,2


PERCENT_RANK

SELECT 
  test_score,
  -- Calculates percentile. 
  -- NULLS LAST ensures missing scores don't get the highest rank.
  PERCENT_RANK() OVER(ORDER BY test_score ASC NULLS LAST) AS percentile
FROM `project.dataset.student_scores`


Aggregate
SUM

#sum with partitioned totals

SELECT
date,
sleep_stage_rank,
sum(duration_hours) as duration_hours,
sum(sum(duration_hours)) over(partition by date) as total_duration_hours
 FROM `my-data-479716.mysql_health_stats.view_sleep_summary`

group by

date,
sleep_stage_rank

LIMIT 1000


AVG

#running avg

select
date,
total_steps,
avg(total_steps) over (order by date rows between 6 preceding and current row) as seven_day_avg
FROM `my-data-479716.mysql_health_stats.view_summary`

select 
date,
sum(cast(duration_hours as decimal)) as total_sleep,
avg(sum(cast(duration_hours as decimal))) over (order by date rows between 6 preceding and current row) as seven_day_avg_sleep

from `my-data-479716.mysql_health_stats.sleep_summary`

group by 1

order by 1


MIN


MAX