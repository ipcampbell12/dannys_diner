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
