
/* Return the winner, name, date, and players of a boardgame. */
SELECT s.game_date, g.name, (pl.fname || ' ' || pl.lname) AS winner,
STRING_AGG(p.fname || ' ' || p.lname, ', ' ORDER BY p.fname,p.lname ) AS players
FROM sessions s
JOIN players_sessions ps
ON s.id = ps.session_id
JOIN players p 
ON ps.player_id = p.id 
JOIN players pl 
ON s.winner_id = pl.id
JOIN games g
ON s.game_id = g.id
GROUP BY s.game_date,g.name, winner 
ORDER BY s.game_date;