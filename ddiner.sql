
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




/*5. What was the first item purchased after they became members? */
SELECT customer, item FROM (SELECT mb.customer_id AS customer,
	mb.join_date, 
	s.order_date,
	me.product_name AS item,
	DENSE_RANK() OVER (PARTITION BY mb.customer_id ORDER BY s.order_date) AS rank
FROM dannys_diner.members mb
JOIN dannys_diner.sales s
ON mb.customer_id = s.customer_id
JOIN dannys_diner.menu me 
ON s.product_id = me.product_id
WHERE s.order_date > mb.join_date) AS sub
WHERE rank = 1;


/* 6 Which item was purchased just before the customer became a member?*/
/* Tricky because customer A purchased two items on the same day before he became a member*/

WITH rank_cte AS 
(SELECT mb.customer_id AS customer,
		mb.join_date,
		s.order_date,
		me.product_name AS item, 
		DENSE_RANK() OVER (PARTITION BY mb.customer_id ORDER BY s.order_date DESC) as rank
		FROM dannys_diner.members mb
		JOIN dannys_diner.sales s
		ON mb.customer_id = s.customer_id
		JOIN dannys_diner.menu me 
		ON s.product_id = me.product_id
		WHERE s.order_date < mb.join_date) 
		
SELECT customer, item FROM rank_cte 
WHERE rank = 1

--7. What is the total items and amount spent for each member before they became a member?--
SELECT mb.customer_id,COUNT(s.product_id) AS total_items,SUM(me.price) AS amount_spent
FROM dannys_diner.members mb 
JOIN dannys_diner.sales s
ON mb.customer_id = s.customer_id
JOIN dannys_diner.menu me 
ON s.product_id = me.product_id
WHERE s.order_date < mb.join_date
GROUP BY mb.customer_id
ORDER BY mb.customer_id






	