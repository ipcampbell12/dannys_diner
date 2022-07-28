--Window functio practice -- 
	-- Find the size of each employee team 
	SELECT employee_id,
		--count how many employees are in each team--
		COUNT(employee_id) OVER (PARTITION BY team_id ORDER BY team_id) AS team_size
	FROM employee;


	--find the top three highest paid employees from each department

	--window function as a subquery
	SELECT department,employee, salary
    FROM (SELECT e.id, 
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
DISTINCT t.id, a.nam
FROM( SELECT 
	id,
	login_date,
	--use 4 because that is the difference between first day and 5th day
	LAG(login_date,4) over (PARTITION BY id ORDER BY login_date) as lag4) t
JOIN accounts accounts
ON a.id = t.id
--verify if it was 4 or not
WHERE DATEDIFF(day, lag4,login_date) =4 
FROM logins



--Partition the smurfs by house--
SELECT 
	smurf, 
	money_earned,
	COUNT(house) OVER(PARTITION BY house) AS count_house
FROM smurfcsv;


--Find which smurf earned the most money--
--don't really need window function for this 
SELECT 
	smurf, 
	money_earned,
	DENSE_RANK() OVER (ORDER BY money_earned DESC)
FROM smurfcsv;

--find top three smurf earners for each house -- 


--Find the top three earners for each house
SELECT name, house, earnings,rank
FROM (SELECT 
		smurf AS name,
		money_earned AS earnings,
	  	house AS house,
		DENSE_RANK() OVER (PARTITION BY house ORDER BY money_earned DESC) as RANK
	FROM smurfcsv) AS sub 
WHERE rank <= 3;


--Find the average pages partitioned by author--
SELECT  title, 
		author_fname,
		author_lname,
		pages,
		ROUND(AVG(pages) OVER(PARTITION BY author_fname,author_lname),0)
FROM books;
