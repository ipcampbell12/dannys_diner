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


--Histogram of tweets 
WITH count_cte AS(
  SELECT COUNT(user_id) AS users_num
  FROM tweets
  WHERE EXTRACT(YEAR from tweet_date) IN (2022)
  GROUP BY user_id
)

SELECT 
ROW_NUMBER() OVER (ORDER BY COUNT(users_num)) AS tweet_bucket,
users_num
FROM count_cte
GROUP BY users_num;


--unfinished parts
SELECT part, assembly_step FROM parts_assembly
WHERE finish_date IS NULL;


--app-ctr

SELECT
  app_id,
  ROUND(100.0*
  SUM(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END)/
  SUM(CASE WHEN event_type = 'impression' THEN 1 ELSE 0 END),2) AS ctr_rate
FROM events
WHERE timestamp BETWEEN '1/1/2022' AND '12/31/2022'
GROUP BY app_id


--second day confirmation

WITH confirm_cte AS(SELECT
    e.user_id, 
    DATE_PART('DAY', e.signup_date) AS signup,
    DATE_PART('DAY', t.action_date) AS action
FROM emails e
JOIN texts t
ON e.email_id = t.email_id
ORDER BY action_date, t.email_id)

SELECT user_id
FROM confirm_cte
WHERE action-signup = 1

--PHARMACY ANALYTICS (PART 1)
WITH profit_cte AS (
  SELECT (total_sales-cogs) AS profit, drug 
  FROM pharmacy_sales
  )
  
SELECT drug, profit 
FROM profit_cte 
ORDER BY profit DESC
LIMIT 3;

--PHARMACY ANALYTICS (PART 2)


  WITH profit_cte AS(
    SELECT drug, manufacturer, (total_sales-cogs) AS profit 
    FROM pharmacy_sales
    )
  
  SELECT manufacturer, COUNT(drug) AS drug_count, SUM(ABS(profit)) AS total_loss
  FROM profit_cte 
  WHERE profit < 0
  GROUP BY manufacturer
  ORDER BY total_loss


--super cloud customer
WITH rankings_cte AS(
  WITH supercloud_cte AS( 
    SELECT 
      cc.customer_id, 
      cc.product_id,
      p.product_category, 
      p.product_name,
      COUNT(p.product_category) OVER(PARTITION BY cc.customer_id) AS category_count
    FROM customer_contracts cc
    JOIN products p
    ON cc.product_id = p.product_id
    ORDER BY customer_id
    )
  
  SELECT 
    customer_id, 
    product_category, 
    DENSE_RANK() OVER (ORDER BY product_category) AS rankings,
    category_count
  FROM supercloud_cte
  WHERE category_count =3 
  ORDER BY customer_id
)

SELECT customer_id FROM rankings_cte 
GROUP BY customer_id
HAVING SUM(rankings) = 6


--Improved version of previous query using COUNT(DISTINCT product_category)
WITH supercloud_cte AS( 
    SELECT 
      cc.customer_id, 
      COUNT(DISTINCT product_category) AS category_count
    FROM customer_contracts cc
    JOIN products p
    ON cc.product_id = p.product_id
    GROUP BY cc.customer_id
    ORDER BY customer_id
)

  SELECT customer_id 
  FROM supercloud_cte
  WHERE category_count = 3 


--SIGNUP ACTIVATION rate
SELECT
  ROUND((COUNT(t.email_id)::DECIMAL/COUNT(DISTINCT e.email_id) ),2) AS activation_rate
FROM emails e 
LEFT JOIN texts t
ON e.email_id = t.email_id AND t.signup_action = 'Confirmed'

--Pharmacy analytics part III
WITH million_cte AS( 
    SELECT manufacturer, SUM(total_sales) AS sale
    FROM pharmacy_sales
    GROUP BY manufacturer
    ORDER BY sale DESC
  )

SELECT manufacturer, CONCAT('$',ROUND(ROUND(sale, -6)/1000000,0),' million') AS sales_mil
FROM million_cte


--DATA SCIENCE SKILLS
SELECT candidate_id FROM candidates
WHERE skill IN ('Python','Tableau','PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(skill)=3
ORDER BY candidate_id;
