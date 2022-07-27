
/*1.What is the total amount each customer spent at the restaurant?*/ 
/*DONE!*/

SELECT s.customer_id, SUM(me.price)
FROM dannys_diner.sales s
JOIN dannys_diner.menu me 
ON s.product_id = me.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;


/*1. How many days has each customer visited the restaurant?*/ 
/*DONE!*/
SELECT  customer_id, COUNT(DISTINCT order_date) FROM dannys_diner.sales
GROUP BY customer_id;




/*1. What was the first menu item that each customer purchased from the restaurant?*/
SELECT DISTINCT s.customer_id, me.product_name FROM dannys_diner.sales s
JOIN dannys_diner.menu me 
ON s.product_id = me.product_id
WHERE s.order_date = (
	SELECT MIN(order_date) FROM dannys_diner.sales)
ORDER BY me.product_name;

/*This one isn't quite working */ 