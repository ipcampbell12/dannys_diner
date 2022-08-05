
-- find the name of each person and their friend (not working)

SELECT s.Name, f.Friend_ID, sf.Name FROM Students s
JOIN Friends f
ON s.ID = f.ID 
JOIN Students sf 
ON sf.ID = f.Friend_ID
WHERE sf.Salary > s.Salary;


--find student who's friend's salary is higher (doesn't work yet)

SELECT p.id, p.name,pa.Salary, f.friend_id, pf.name AS friend, pas.salary AS friend_salary FROM people p
JOIN friends f
ON p.id = f.id
JOIN people pf 
ON f.friend_id = pf.id
JOIN packages pa 
ON pf.id = pa.id
JOIN friends sf
ON p.id = sf.id 
JOIN packages pas
ON sf.id = pas.id;
