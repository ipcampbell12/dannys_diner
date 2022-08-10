


--find student who's friend's salary is higher 

SELECT s.Name FROM Students s
JOIN Friends f
ON s.ID = f.ID 
JOIN Students sf 
ON sf.ID = f.Friend_ID 
JOIN Packages p 
ON s.ID = p.ID 
JOIN packages pas  
ON sf.id = pas.id
WHERE pas.salary > p.salary
ORDER BY pas.salary;



--find friends' friend

SELECT p.id, p.name,pa.Salary, f.friend_id, pf.name AS friend, pas.salary AS friend_salary FROM people p
JOIN friends f
ON p.id = f.id
JOIN people pf 
ON f.friend_id = pf.id



