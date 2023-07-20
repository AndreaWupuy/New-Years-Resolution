--Database - Downloaded from Maven Analytics database --
use [New Years Resolution]
SELECT * 
FROM [New_years_resolutions_2020];

--A.Category:
--A.1. What is the most popular resolution category? Least popular? --
SELECT DISTINCT COUNT(tweet_category) AS category_count, tweet_category
FROM [New_years_resolutions_2020]
GROUP BY tweet_category
ORDER BY category_count DESC;

--A.2. What is the most popular resolution category by state? --
WITH ranks AS (
    select DISTINCT COUNT(tweet_category) AS total_count, 
           tweet_category,
           tweet_state, 
           row_number() over (partition by tweet_state order by COUNT(tweet_category) DESC) AS state_rank 
    from New_years_resolutions_2020
	GROUP BY tweet_category, tweet_state)
SELECT * FROM ranks
	where ranks.state_rank <= 1
group by ranks.tweet_category, ranks.tweet_state, ranks.total_count, ranks.state_rank;

--A.3. What is the least popular resolution category by state? --
WITH ranks AS (
    select DISTINCT COUNT(tweet_category) AS total_count, 
           tweet_category,
           tweet_state, 
           row_number() over (partition by tweet_state order by COUNT(tweet_category) ASC) AS state_rank 
    from New_years_resolutions_2020
	GROUP BY tweet_category, tweet_state)
SELECT * FROM ranks
	where ranks.state_rank <= 1
group by ranks.tweet_category, ranks.tweet_state, ranks.total_count, ranks.state_rank

SELECT DISTINCT tweet_state
from New_years_resolutions_2020;

--A.4. Which resolution category was retweeted the most? Least?--
SELECT DISTINCT SUM(retweet_count) AS total_retweet, tweet_category
FROM [New_years_resolutions_2020]
GROUP BY tweet_category
ORDER BY total_retweet DESC;


--A.5. What is the most popular resolution topic? 
SELECT DISTINCT TOP 5 COUNT(tweet_category) AS category_count, tweet_topics, tweet_category
FROM [New_years_resolutions_2020]
GROUP BY tweet_topics, tweet_category
ORDER BY category_count DESC;

--A.6. What is the least popular resolution topic? 
SELECT DISTINCT TOP 5 COUNT(tweet_category) AS category_count, tweet_topics, tweet_category
FROM [New_years_resolutions_2020]
GROUP BY tweet_topics, tweet_category
ORDER BY category_count ASC;


--A.7. Which resolution topic was retweeted the most?--
SELECT TOP 5 SUM(retweet_count) AS retweet_count, tweet_topics, tweet_category 
FROM [New_years_resolutions_2020]
WHERE retweet_count IS NOT NULL
GROUP BY tweet_topics, tweet_category
ORDER BY SUM(retweet_count) DESC;

--A.8. Which resolution topic was retweeted the least?--
SELECT TOP 5 SUM(retweet_count) AS retweet_count, tweet_topics, tweet_category 
FROM [New_years_resolutions_2020]
WHERE retweet_count IS NOT NULL
GROUP BY tweet_topics, tweet_category
ORDER BY SUM(retweet_count) ASC;


-- B. By time --
--B.1 Rounding to the nearest hour, what was the most popular hour of day to tweet? How many resolutions were tweeted?--
SELECT DISTINCT TOP 5 datepart(hh,tweet_created) AS hours_tweeted, COUNT(tweet_text) AS total_tweets
FROM [New_years_resolutions_2020]
GROUP BY datepart(hh,tweet_created)
ORDER BY total_tweets DESC;

--B.2 Rounding to the nearest hour, what was the most popular hour of day to tweet by State? How many resolutions were tweeted?--
WITH ranks AS (
    select DISTINCT datepart(hh,tweet_created) AS hours_tweeted, 
	COUNT(tweet_text) AS total_tweets, 
	tweet_state,
    row_number() over (partition by tweet_state order by COUNT(tweet_category) DESC) AS state_rank 
    from New_years_resolutions_2020
	GROUP BY datepart(hh,tweet_created), tweet_state)
SELECT * FROM ranks
	where ranks.state_rank <= 1
group by ranks.tweet_state, ranks.total_tweets, ranks.state_rank, ranks.hours_tweeted;

--B.3 What day was the most tweeted? How many resolutions were tweeted?--
SELECT DISTINCT datepart(dd,tweet_created) AS days_tweeted, datepart(MONTH,tweet_created) AS month_tweeted, COUNT(tweet_text) AS total_tweets
FROM [New_years_resolutions_2020]
GROUP BY datepart(dd,tweet_created), datepart(MONTH,tweet_created)
ORDER BY total_tweets DESC;

-- C. By State --
-- C.1 What U.S. State tweeted the highest number of NYE resolutions?--
SELECT TOP 5 tweet_state, COUNT(tweet_topics) AS total_tweets
FROM [New_years_resolutions_2020]
GROUP BY tweet_state
ORDER BY total_tweets DESC;

-- C.2 What U.S. State tweeted the least number of NYE resolutions?--
SELECT TOP 5 tweet_state, COUNT(tweet_topics) AS total_tweets
FROM [New_years_resolutions_2020]
GROUP BY tweet_state
ORDER BY total_tweets ASC;

--By Gender --
--D.1 Who tweeted the most? --
SELECT DISTINCT COUNT(tweet_category) AS category_count, user_gender, 
				FORMAT(round(COUNT(tweet_category) * 1.0/(SELECT COUNT(tweet_category) FROM [New_years_resolutions_2020]),2,1),'0.00') AS perctg_tweets
FROM [New_years_resolutions_2020]
GROUP BY user_gender
ORDER BY category_count DESC;

--D.2. What twitter cathegory was the most tweeted by gender?--
SELECT DISTINCT COUNT(tweet_category) AS category_count, tweet_category, user_gender
FROM [New_years_resolutions_2020]
GROUP BY user_gender, tweet_category
ORDER BY category_count DESC;

--D.3. What twitter cathegory was the most retweeted by gender?--
SELECT DISTINCT SUM(retweet_count) AS total_retweet, tweet_category, user_gender
FROM [New_years_resolutions_2020]
GROUP BY user_gender, tweet_category
ORDER BY total_retweet DESC;

--D.4. What topic was the most tweeted by gender?--
SELECT DISTINCT TOP 2 COUNT(tweet_category) AS category_count, tweet_topics, tweet_category, user_gender
FROM [New_years_resolutions_2020]
GROUP BY tweet_category, user_gender, tweet_topics
ORDER BY category_count DESC;

--D.5. What topic was the least tweeted by gender?--
SELECT DISTINCT TOP 5 COUNT(tweet_category) AS category_count, tweet_topics, tweet_category, user_gender
FROM [New_years_resolutions_2020]
GROUP BY tweet_category, user_gender, tweet_topics
ORDER BY category_count ASC;

