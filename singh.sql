--Average days between posts per user

WITH days_cte AS (
    SELECT 
      user_id, 
      post_date,
      LAG(post_date,1) OVER (PARTITION BY user_id ORDER BY post_date),
      (post_date - LAG(post_date,1) OVER (PARTITION BY user_id ORDER BY post_date)) AS num_days
    FROM posts
    WHERE to_char(post_date,'yyyy')='2021')

SELECT user_id, ROUND(EXTRACT( DAY FROM AVG(num_days))+.5) AS average_days
FROM days_cte
GROUP BY user_id
HAVING COUNT(user_id) >= 2
ORDER BY user_id;


--first transaction over 50 dollars

WITH row_cte AS (
      SELECT user_id,
       transaction_date,
       spend,
       ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date)
       AS row
      FROM user_transactions)
      
SELECT COUNT(user_id) AS users 
FROM row_cte 
WHERE row = 1 AND spend >50;


--3 day rolling average of tweets per user

WITH tweets_cte AS (
SELECT user_id, tweet_date, COUNT(DISTINCT tweet_id) AS tc
FROM tweets
GROUP BY user_id, tweet_date) 

SELECT user_id, 
       tweet_date, 
      ROUND(AVG(tc) OVER (PARTITION BY user_id ORDER BY tweet_date 
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)
FROM tweets_cte; 



--average stars per month

SELECT month,product,ROUND(AVG(avg_stars),2) 
FROM (SELECT EXTRACT(MONTH FROM submit_date) AS month, 
      product_id AS product,
      AVG(stars) AS avg_stars
      FROM reviews
      GROUP BY month,product
      )AS sub
GROUP BY month,product
ORDER BY month,product


--sending vs. opening snaps 

--SELECT * FROM activities;
  WITH activity_cte AS(
      SELECT ab.age_bucket, a.activity_type, SUM(a.time_spent) AS total, 
      SUM(SUM(a.time_spent)) OVER (PARTITION BY ab.age_bucket) AS total_of_totals
      FROM activities a 
      JOIN age_breakdown ab
      ON a.user_id = ab.user_id
      WHERE a.activity_type = 'open' OR a.activity_type = 'send'
      GROUP BY activity_type, age_bucket
      ORDER BY age_bucket)
      
  SELECT age_bucket, 
         SUM(CASE WHEN activity_type = 'send' THEN ROUND((total/total_of_totals)*100.0,2) END) AS send_perc,
         SUM(CASE WHEN activity_type = 'open' THEN ROUND((total/total_of_totals)*100.0,2) END) AS open_perc
  
  FROM activity_cte
  GROUP BY age_bucket;

  




--user session activity
WITH rank_cte AS(
    SELECT user_id, 
           session_type, 
           SUM(duration) AS total_duration
    FROM sessions
    WHERE start_date BETWEEN '2022-01-01' AND '2022-02-01'
    GROUP BY user_id,session_type)
    
SELECT user_id, 
       session_type,
       DENSE_RANK() OVER (PARTITION BY session_type ORDER BY total_duration DESC)
FROM rank_cte;


--linkedin power creators part 1

WITH followers_cte AS (
  SELECT p.profile_id,p.followers AS personal ,cp.followers  AS company FROM personal_profiles p
  JOIN company_pages cp
  ON p.employer_id = cp.company_id)
  
SELECT profile_id FROM followers_cte 
WHERE personal > company
ORDER BY profile_id

--Third transcation
WITH row_cte AS (
  SELECT
  user_id,
  spend,
  transaction_date,
  ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date) AS row
  FROM transactions
   )

SELECT user_id,spend, transaction_date FROM row_cte 
WHERE row = 3;