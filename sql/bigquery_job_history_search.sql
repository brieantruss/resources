SELECT
  job_id,
  user_email,
  creation_time,
  query,
  labels
FROM
  `arvig-report-data.region-us`.INFORMATION_SCHEMA.JOBS
WHERE
  query LIKE '%SELECT `workflow_executable_id` AS `workflow_executable_id`, `workflow_id` AS `workflow_id`, `executable_status_id` AS `executable_status_id`, `external_id` AS `external_id`, `created_at` AS `created_at`, %'

and user_email = 'briean.truss.ra@arvig.com'
and cast(creation_time as date) = '2026-09-09'
ORDER BY
  creation_time DESC;
