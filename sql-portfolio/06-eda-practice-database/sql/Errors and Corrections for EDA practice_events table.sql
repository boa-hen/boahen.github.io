-- Errors and their corrections for Events table

SELECT DISTINCT app_id, COUNT(*)
FROM `events`
GROUP BY app_id
;
# this query gives a count of everthing in the table grouped by app_id, at first glance this may seem like the correct approach to getting the counts of event_type
# but this does not give the individual counts, using this approach means we have to include event_type in the select statement and also group by it too
# This however results in later issues that makes calculating the ctr ratio difficult

WITH CTR_percentage as
(
SELECT DISTINCT app_id, event_type, COUNT(*)
FROM `events`
GROUP BY app_id, event_type
)
SELECT *
FROM CTR_percentage
;
# the output of this separates the counts of both event_types but put them on different rows too, this becomes a problem when calculating the ctr ratio
# as evidenced below

SELECT DISTINCT app_id, event_type, COUNT(*) as num,
CASE
	WHEN app_id = 1 THEN (event_type='click'/event_type='impression')*100
    WHEN app_id = 2 THEN (event_type='click'/event_type='impression')*100
    WHEN app_id = 3 THEN (event_type='click'/event_type='impression')*100
    ELSE 0
END as ctr_calc
FROM `events`
GROUP BY event_type
;
# This outputs null for the ctr_calc column because MySQL tries to divide the string 'click' by the column event_type.
# Both convert to 0, which is a division by zero, which gives NULL, and NULL spreads through the rest of the calculation.

# we want to calculate the conversion rate percentage using the formula (clicks/impressions) * 100
# we have to count the clicks and impressions for each app_id, the value of the counts is what will be used fir the calculation
# the count function can give us the count of all values in the event_type column, however to separately show the counts of clicks and impressions would require us to group by event_type
# this presents a problem because we cannot group by only event_id since it was not the only non-aggregate column selected
# we will need to group by both app_id and event_type and this brings us back to square one

# CORRECTION
# The more feasible method is to use SUM instead of COUNT. SUM can also be used to count values if done properly.
# This gives us precisely what we want and rounds the final value to 2 decimal points.

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
SELECT ROUND((clicks/NULLIF(impressions, 0)) * 100, 2)
FROM ctr_rate
;

