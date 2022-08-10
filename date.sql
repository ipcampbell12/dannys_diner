--use to_char and EXTRACT to get different pieces of information from a date


SELECT CONCAT(smurf, ' returned on ', to_char(return_date,'Day'),' ',
	   to_char(return_date,'Month'),
	   EXTRACT(DAY FROM return_date),', ',
	   EXTRACT(YEAR FROM return_date)) 
FROM smurfcsv;

--use to_char to format date with templaate

SELECT to_char(return_date, 'Day Month DD, YYYY')
FROM smurfcsv;