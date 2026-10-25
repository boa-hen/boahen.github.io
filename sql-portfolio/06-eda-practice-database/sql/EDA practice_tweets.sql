-- Table 8

SELECT *
FROM tweets;

SELECT *,
ROW_NUMBER() OVER(PARTITION BY user_id, tweet_date ORDER BY tweet_id) as row_num
FROM tweets
;
# the results from this query shows some duplicates but since these are tweets it can be interpreted as multiple tweets from one user

SELECT *
FROM tweets
WHERE tweet_id IS NULL
;

SELECT *
FROM tweets
WHERE user_id IS NULL
;

SELECT *
FROM tweets
WHERE tweet_date IS NULL
;
# there are no null or empty values

SELECT user_id, COUNT(*) as num_of_tweets
FROM tweets
GROUP BY user_id
;

SELECT user_id, COUNT(*) AS num_of_tweets,
CASE
	WHEN COUNT(*) BETWEEN 1 AND 5 THEN '1-5 tweets'
    WHEN COUNT(*) BETWEEN 6 AND 10 THEN '6-10 tweets'
    WHEN COUNT(*) BETWEEN 11 AND 20 THEN '11-20 tweets'
    ELSE '20+ tweets'
END as freq
FROM tweets
GROUP BY user_id
;

WITH tweets_stats as
(
SELECT user_id, COUNT(*) AS num_of_tweets,
CASE
	WHEN COUNT(*) BETWEEN 1 AND 5 THEN '1-5 tweets'
    WHEN COUNT(*) BETWEEN 6 AND 10 THEN '6-10 tweets'
    WHEN COUNT(*) BETWEEN 11 AND 20 THEN '11-20 tweets'
    ELSE '20+ tweets'
END as freq
FROM tweets
GROUP BY user_id
)
SELECT DISTINCT freq, COUNT(*) OVER(PARTITION BY freq) as freq_count
FROM tweets_stats
ORDER BY freq
;

SELECT DISTINCT tweet_date, COUNT(*) as tweets_per_date
FROM tweets
GROUP BY tweet_date
;

SELECT DISTINCT tweet_date, dayname(tweet_date), COUNT(*) as tweets_per_date
FROM tweets
GROUP BY tweet_date
;

SELECT dayname(tweet_date), COUNT(*) as tweets_per_date
FROM tweets
GROUP BY dayname(tweet_date)
;

SELECT dayofweek(tweet_date), dayname(tweet_date), COUNT(*)
FROM tweets
GROUP BY dayofweek(tweet_date), dayname(tweet_date)
;
