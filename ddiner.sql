
/*1.What is the total amount each customer spent at the restaurant?*/ 
/*DONE!*/

SELECT s.customer_id, SUM(me.price)
FROM dannys_diner.sales s
JOIN dannys_diner.menu me 
ON s.product_id = me.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;


/*2. How many days has each customer visited the restaurant?*/ 
/*DONE!*/
SELECT  customer_id, COUNT(DISTINCT order_date) FROM dannys_diner.sales
GROUP BY customer_id;


/*3. What was the first menu item that each customer purchased from the restaurant?*/
SELECT DISTINCT s.customer_id, me.product_name FROM dannys_diner.sales s
JOIN dannys_diner.menu me 
ON s.product_id = me.product_id
WHERE s.order_date = (
	SELECT MIN(order_date) FROM dannys_diner.sales)
ORDER BY me.product_name;

/*This one isn't quite working */ 



/*4. What is the most purchased item on the menu and how many times was 
it purchased by all customers?*/

SELECT customer_id, COUNT(product_id) as count_favorite FROM dannys_diner.sales
WHERE product_id = (SELECT product_id FROM (SELECT product_id, COUNT(product_id) AS count FROM dannys_diner.sales
GROUP BY product_id ORDER BY count DESC limit 1) AS sub)
GROUP BY customer_id;





	--Window functio practice -- 
	-- Find the size of each employee team 
	SELECT employee_id,
		--count how many employees are in each team--
		COUNT(employee_id) OVER (PARTITION BY team_id ORDER BY team_id) AS team_size
	FROM employee;


	--find the top three highest paid employees from each department

	--window function as a subquery
	SELECT department,employee, salary
	(SELECT e.id, 
		e.name AS employee,
		e.Salary AS salary,
		d.name AS department,
		--grooups them by department and orders them by salary, hightest to lowest
		DENSE_RANK() OVER (PARTITION BY d.id ORDER BY Salary DESC ) AS rank
	FROM employee e
	JOIN Department d
	ON e.departmentId = d.departmentId ) AS sub
	WHERE rank <= 3


--Analytic functionS
--check which users have logged in for at least 5 days in a row 
SELECT 
	id,
	login_date,
	--use 4 because that is the difference between first day and 5th day
	LAG(login_date,4) over (PARTITION BY id ORDER BY login_date) as lag4
FROM logins


