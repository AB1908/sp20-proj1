DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear FROM people WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear FROM people WHERE namefirst ~ '.* .*'
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, avg(height) AS avgheight, count(*) AS count FROM people GROUP BY birthyear ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT * FROM q1iii WHERE avgheight > 70 ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, h.playerid, h.yearid FROM people p JOIN halloffame h ON p.playerid = h.playerid
    WHERE h.inducted = 'Y'
    ORDER BY yearid DESC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
   SELECT p.namefirst, p.namelast, p.playerid, c.schoolid, h.yearid FROM people p
    JOIN collegeplaying c ON p.playerid = c.playerid 
    JOIN schools s ON c.schoolid = s.schoolid
    JOIN halloffame h ON p.playerid = h.playerid
    WHERE s.schoolstate = 'CA' AND h.inducted = 'Y'
    ORDER BY h.yearid DESC, p.playerid ASC, c.schoolid ASC, p.playerid ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
   SELECT p.playerid, p.namefirst, p.namelast, c.schoolid FROM people p
    JOIN halloffame h ON p.playerid = h.playerid
    LEFT JOIN collegeplaying c ON p.playerid = c.playerid
    WHERE h.inducted = 'Y'
    ORDER BY p.playerid DESC, c.schoolid ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, p.namefirst, p.namelast, b.yearid, 
  ((h * 1 - h2b - h3b - hr + 2 * h2b + 3 * h3b + hr * 4) / CAST(ab AS FLOAT)) AS slg
   FROM people p JOIN batting b on b.playerid = p.playerid where ab > 50
   ORDER BY slg DESC, yearid ASC, playerid ASC
   LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, p.namefirst, p.namelast,
  (SUM(h * 1 - h2b - h3b - hr + 2 * h2b + 3 * h3b + hr * 4) / CAST(SUM(ab) AS FLOAT)) AS lslg
   FROM people p JOIN batting b on b.playerid = p.playerid GROUP BY p.playerid HAVING SUM(ab) > 50
   ORDER BY lslg DESC, playerid ASC
   LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH Q AS (
    SELECT p.playerid, p.namefirst, p.namelast,
    (SUM(h * 1 - h2b - h3b - hr + 2 * h2b + 3 * h3b + hr * 4) / CAST(SUM(ab) AS FLOAT)) AS lslg
    FROM people p JOIN batting b on b.playerid = p.playerid GROUP BY p.playerid HAVING SUM(ab) > 50
  ) SELECT q.namefirst, q.namelast, q.lslg FROM Q WHERE q.lslg > ALL (SELECT q.lslg FROM Q WHERE q.playerid = 'mayswi01')
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary), STDDEV(salary) FROM salaries
    GROUP BY yearid ORDER BY yearid ASC
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH X AS (
    SELECT MIN(salary), MAX(salary) FROM salaries WHERE yearid = '2016'
  ), ITEMS AS (
    SELECT i as binid, i * (X.max - X.min)/10.0 + X.min AS low,
      (i + 1) * (X.max - X.min)/10.0 + X.min AS high
      FROM generate_series(0, 9) AS i, X
  ) SELECT binid, low, high, COUNT(*) FROM salaries JOIN ITEMS ON 
    low <= salary AND ( binid = 9 AND salary <= high OR salary < high )
    WHERE yearid = '2016' 
    GROUP BY binid, low, high
    ORDER BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH S AS (
    SELECT yearid, MIN(salary), MAX(salary), AVG(salary) FROM salaries
      GROUP BY yearid
  ) SELECT s1.yearid, s1.min - s2.min AS mindiff, s1.max - s2.max as maxdiff,
    s1.avg - s2.avg AS avgdiff
    FROM S s1 JOIN S s2 ON s1.yearid = s2.yearid + 1
    ORDER BY s1.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH benchmark AS (
    SELECT yearid, MAX(salary) FROM salaries WHERE (
      yearid = 2001 OR yearid = 2000) GROUP BY yearid
  ), players AS (
    SELECT s.yearid, playerid, salary FROM salaries s JOIN
      benchmark b ON s.yearid = b.yearid WHERE s.salary >= b.max
  ) SELECT p1.playerid, p1.namefirst, p1.namelast, p2.salary, p2.yearid
    FROM people p1 JOIN players p2 ON p1.playerid = p2.playerid
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  WITH Q AS (
    SELECT a.teamid, max(salary), min(salary) FROM allstarfull a
        JOIN salaries s ON a.playerid = s.playerid AND a.yearid = s.yearid
        WHERE s.yearid = 2016 and a.yearid = 2016
        GROUP BY a.teamid
  ) SELECT teamid, max - min AS avgdiff FROM Q
  ORDER BY teamid
;

