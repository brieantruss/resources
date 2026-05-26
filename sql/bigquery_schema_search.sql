SELECT distinct 
table_name,
column_name
#FROM `arvig-report-data.salesforce_production.INFORMATION_SCHEMA.COLUMNS`
#FROM `arvig-report-data.idi_replica_dbo.INFORMATION_SCHEMA.COLUMNS`
#FROM `arvig-report-data.idi_replica_ord.INFORMATION_SCHEMA.COLUMNS`
#FROM `arvig-report-data.azure_netbox_data.INFORMATION_SCHEMA.COLUMNS`
#FROM `arvig-report-data.WORKSHOP_SDA.INFORMATION_SCHEMA.COLUMNS`
FROM `arvig-report-data.GAPI_AWE.INFORMATION_SCHEMA.COLUMNS`
WHERE 1=1
#and lower(table_name) like '%map_draw%'
and lower(column_name) like '%exchange%'
order by 2

/*

SELECT
  *
FROM
  ML.DESCRIBE_DATA(TABLE `arvig-report-data.JDE.budgets_and_actuals_capital`)

  */
