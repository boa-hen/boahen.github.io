-- Table 2

SELECT *
FROM `events`;

SELECT DISTINCT event_type
FROM `events`
;

SELECT DISTINCT event_date
FROM `events`
;

SELECT DISTINCT app_id
FROM `events`
;

SELECT *
FROM `events` as e1
LEFT JOIN `events` as e2
	ON e1.app_id = e2.app_id
    AND e1.event_date = e2.event_date
    AND e2.event_type = 'impression'
    WHERE e1.event_type = 'click'
    AND e2.event_id IS NULL
;



SELECT app_id,
SUM(event_type = 'click') clicks,
SUM(event_type = 'impression') impressions
FROM `events`
GROUP BY app_id
;

WITH ctr_rate as
(
SELECT app_id,
SUM(event_type = 'click') clicks,
SUM(event_type = 'impression') impressions
FROM `events`
GROUP BY app_id
)
SELECT app_id,
ROUND((clicks/NULLIF(impressions, 0)) * 100, 2) as rounded_ctr
FROM ctr_rate
GROUP BY app_id
;
# the results from this output shows the conversion rate of the 3 different apps


SELECT app_id, event_date,
SUM(event_type = 'click') clicks,
SUM(event_type = 'impression') impressions
FROM `events`
GROUP BY app_id, event_date
;

WITH ctr_per_day as
(
SELECT app_id, event_date,
SUM(event_type = 'click') clicks,
SUM(event_type = 'impression') impressions
FROM `events`
GROUP BY app_id, event_date
)
SELECT app_id, event_date,
(clicks/NULLIF(impressions, 0)) * 100 as ctr_per_d
FROM ctr_per_day
GROUP BY app_id, event_date
;
# this shows the conversion rate of the 3 apps per each of the dates present in the data
