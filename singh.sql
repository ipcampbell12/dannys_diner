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
WITH month_cte AS (SELECT EXTRACT(MONTH FROM submit_date) AS month, 
       product_id AS product,
       stars 
FROM reviews) 

SELECT month, 
       product,
       ROUND(AVG(stars) OVER (ORDER BY month),2)
FROM month_cte
GROUP BY month,product;