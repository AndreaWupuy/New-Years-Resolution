--Database - Downloaded from Maven Analytics database --
use [New Years Resolution]
SELECT * 
FROM [New_years_resolutions_2020];

--1.Category:
-- Number of categories
SELECT (tweet_category) 
FROM [New_years_resolutions_2020]
GROUP BY tweet_category

--1.1. What is the most popular resolution category? Least popular? --
SELECT DISTINCT COUNT(tweet_category) AS category_count, tweet_category
FROM [New_years_resolutions_2020]
GROUP BY tweet_category
ORDER BY category_count DESC;

--1.2. What is the most popular resolution category by state? --
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

--1.3. What is the least popular resolution category by state? --
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

--1.4. Which resolution category was retweeted the most? Least?--
SELECT DISTINCT SUM(retweet_count) AS total_retweet, tweet_category
FROM [New_years_resolutions_2020]
GROUP BY tweet_category
ORDER BY total_retweet DESC;

--1.5 Tweets & Retweets per category 
SELECT DISTINCT COUNT(tweet_category) AS total_tweet, SUM(retweet_count) AS total_retweet,  tweet_category
FROM [New_years_resolutions_2020]
GROUP BY tweet_category
ORDER BY total_tweet DESC;

--1.6 Total topics
SELECT tweet_topics
FROM [New_years_resolutions_2020]
GROUP BY tweet_topics

--1.7. What is the most popular resolution topic? 
SELECT DISTINCT TOP 5 COUNT(tweet_category) AS category_count, tweet_topics, tweet_category
FROM [New_years_resolutions_2020]
GROUP BY tweet_topics, tweet_category
ORDER BY category_count DESC;

--1.8. What is the least popular resolution topic? 
SELECT DISTINCT TOP 5 COUNT(tweet_category) AS category_count, tweet_topics, tweet_category
FROM [New_years_resolutions_2020]
GROUP BY tweet_topics, tweet_category
ORDER BY category_count ASC;

-- 1.9 Tweets & Retweets per topic
SELECT DISTINCT TOP 10 COUNT(tweet_category) AS total_tweet, SUM(retweet_count) AS total_retweet, tweet_topics, tweet_category
FROM [New_years_resolutions_2020]
GROUP BY tweet_topics, tweet_category
ORDER BY total_retweet DESC;
-- ORDER BY total_retweet DESC --


-- 1.10 Wordlist (1 word)
-- List of common English pronouns and articles to exclude
DECLARE @stopwords TABLE (word NVARCHAR(50));
INSERT INTO @stopwords (word) VALUES
    ('to'), ('my'), ('new'), ('i'), ('is'), ('the'), ('a'), ('in'), ('of'), ('for'),
    ('on'), ('this'), ('that'), ('as'), ('so'), ('me'), ('you'), ('all'), ('at'), ('no'), (' '), ('and'), ('with'),('rt'),('resolution'),('years'), ('will'),('it');

-- Query to get the word count, excluding pronouns and articles
SELECT TOP 15 word, COUNT(*) AS word_count
FROM (
    SELECT value AS word
    FROM [New_years_resolutions_2020]
    CROSS APPLY STRING_SPLIT(lower(tweet_text), ' ')
) AS words
WHERE word NOT IN (SELECT word FROM @stopwords)
GROUP BY word
ORDER BY word_count DESC;

-- 1.11 Wordlist (2 words)
-- List of common English pronouns and articles to exclude
DECLARE @stopwords TABLE (word NVARCHAR(50));
INSERT INTO @stopwords (word) VALUES
    ('is to'), ('to be'), ('to get'), ('going to'), ('to stop'), ('i will'), ('to make'), ('in the'), (' '), ('for the'),
    ('of my'), ('go to'), ('be a'), ('to the'), ('to not'), ('i have'), ('#newyearsresolution'), ('new years'),
	('my #newyearsresolution'), ('#newyearsresolution my'), ('#newyearsresolution to'),('#newyearsresolution rt'),
	('#newyearsresolution I'), ('#newyearsresolution is'), ('#newyearsresolution #newyearsresolution '),('#newyearsresolution stop'),(' #newyearsresolution'),
	('new years'),('my new'), ('years resolution'), ('years resolution:'), ('resolution is'), ('#newyearsresolution for'), ('on my'), ('of the');

-- Query to get the word pair count, excluding words above
SELECT top 15 word_pair, COUNT(*) AS pair_count
FROM (
    SELECT CONCAT(prev_word, ' ', curr_word) AS word_pair
    FROM (
        SELECT 
            LAG(value) OVER (ORDER BY (SELECT NULL)) AS prev_word,
            value AS curr_word
        FROM [New_years_resolutions_2020]
        CROSS APPLY STRING_SPLIT(lower(tweet_text), ' ')
    ) AS word_pairs
    WHERE prev_word IS NOT NULL
) AS cleaned_word_pairs
WHERE word_pair NOT IN (SELECT word FROM @stopwords)
GROUP BY word_pair
ORDER BY pair_count DESC;

-- 1.12 Wordlist (3 words)
-- List of common English pronouns and articles to exclude
DECLARE @stopwords TABLE (word NVARCHAR(50));
INSERT INTO @stopwords (word) VALUES
    ('new years resolution'), ('my new years'), ('#newyearsresolution is to'), ('years resolution is'), ('#newyearsresolution my #newyearsresolution'), 
	('my #newyearsresolution is'), ('new years resolution:'), ('   '), ('resolution is to');

-- Query to get the word trio count, excluding words above
SELECT TOP 15 word_trio, COUNT(*) AS trio_count
FROM (
    SELECT CONCAT(prev_word, ' ', curr_word, ' ', next_word) AS word_trio
    FROM (
        SELECT 
            LAG(value, 1) OVER (ORDER BY (SELECT NULL)) AS prev_word,
            value AS curr_word,
            LEAD(value, 1) OVER (ORDER BY (SELECT NULL)) AS next_word
        FROM [New_years_resolutions_2020]
        CROSS APPLY STRING_SPLIT(lower(tweet_text), ' ')
    ) AS word_trios
    WHERE prev_word IS NOT NULL AND next_word IS NOT NULL
) AS cleaned_word_trios
WHERE word_trio NOT IN (SELECT word FROM @stopwords)
GROUP BY word_trio
ORDER BY trio_count DESC;


--1.13. Which resolution topic was retweeted the most?--
SELECT TOP 5 SUM(retweet_count) AS retweet_count, tweet_topics, tweet_category 
FROM [New_years_resolutions_2020]
WHERE retweet_count IS NOT NULL
GROUP BY tweet_topics, tweet_category
ORDER BY SUM(retweet_count) DESC;

--1.14. Which resolution topic was retweeted the least?--
SELECT TOP 5 SUM(retweet_count) AS retweet_count, tweet_topics, tweet_category 
FROM [New_years_resolutions_2020]
WHERE retweet_count IS NOT NULL
GROUP BY tweet_topics, tweet_category
ORDER BY SUM(retweet_count) ASC;


-- 2. By time --
--2.1 Rounding to the nearest hour, what was the most popular hour of day to tweet? How many resolutions were tweeted?--
SELECT DISTINCT TOP 5 datepart(hh,tweet_created) AS hours_tweeted, COUNT(tweet_text) AS total_tweets
FROM [New_years_resolutions_2020]
GROUP BY datepart(hh,tweet_created)
ORDER BY total_tweets DESC;

--2.2 Rounding to the nearest hour, what was the most popular hour of day to tweet by State? How many resolutions were tweeted?--
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

--2.3 What day was the most tweeted? How many resolutions were tweeted?--
SELECT DISTINCT TOP 5 datepart(dd,tweet_created) AS days_tweeted, datepart(MONTH,tweet_created) AS month_tweeted, COUNT(tweet_text) AS total_tweets
FROM [New_years_resolutions_2020]
GROUP BY datepart(dd,tweet_created), datepart(MONTH,tweet_created)
ORDER BY total_tweets DESC;

SELECT DISTINCT TOP 3 datepart(dd,tweet_created) AS days_tweeted, datepart(MONTH,tweet_created) AS month_tweeted, SUM(retweet_count) AS total_retweet
FROM [New_years_resolutions_2020]
GROUP BY datepart(dd,tweet_created), datepart(MONTH,tweet_created)
ORDER BY total_retweet DESC;


-- 3. By State --
-- 3.1 What U.S. State tweeted the highest number of NYE resolutions?--
SELECT TOP 5 tweet_state, COUNT(tweet_topics) AS total_tweets, SUM(retweet_count) AS total_retweet
FROM [New_years_resolutions_2020]
GROUP BY tweet_state
ORDER BY total_tweets DESC;
--ORDER BY total_retweet DESC;


-- 3.2 What U.S. State tweeted the least number of NYE resolutions?--
SELECT TOP 5 tweet_state, COUNT(tweet_topics) AS total_tweets
FROM [New_years_resolutions_2020]
GROUP BY tweet_state
ORDER BY total_tweets ASC;

--4. By Gender --
--4.1 Who tweeted the most? --
SELECT DISTINCT COUNT(tweet_category) AS category_count, user_gender, 
				FORMAT(round(COUNT(tweet_category) * 1.0/(SELECT COUNT(tweet_category) FROM [New_years_resolutions_2020]),2,1),'0.00') AS perctg_tweets
FROM [New_years_resolutions_2020]
GROUP BY user_gender
ORDER BY category_count DESC;

--4.2. What twitter cathegory was the most tweeted by gender?--
SELECT DISTINCT top 10 COUNT(tweet_category) AS category_count, tweet_category, user_gender
FROM [New_years_resolutions_2020]
GROUP BY user_gender, tweet_category
ORDER BY category_count DESC;

--4.3. What twitter cathegory was the most retweeted by gender?--
SELECT DISTINCT SUM(retweet_count) AS total_retweet, tweet_category, user_gender
FROM [New_years_resolutions_2020]
GROUP BY user_gender, tweet_category
ORDER BY total_retweet DESC;

--4.4. What topic was the most tweeted by gender?--
SELECT DISTINCT TOP 2 COUNT(tweet_category) AS category_count, tweet_topics, tweet_category, user_gender
FROM [New_years_resolutions_2020]
GROUP BY tweet_category, user_gender, tweet_topics
ORDER BY category_count DESC;

--4.5. What topic was the least tweeted by gender?--
SELECT DISTINCT TOP 5 COUNT(tweet_category) AS category_count, tweet_topics, tweet_category, user_gender
FROM [New_years_resolutions_2020]
GROUP BY tweet_category, user_gender, tweet_topics
ORDER BY category_count ASC;

