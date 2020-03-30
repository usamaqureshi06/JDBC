/******************************************************************************
 * EECS3421: Introduction to Databases
 * Assignment 2: Interactive and Embedded SQL
 * Student Name: Umar Abdulselam, Tamim Chowdhury
 * Student EECS account: uaabduls, tamim1
 * Student ID: 215995616, 213687272
 ******************************************************************************/

SET search_path TO A2;
-- Add below your SQL statements.
-- For each of the queries below, your final statement should populate the respective answer table (queryX) with the correct tuples. It should look something like:
-- INSERT INTO queryX (SELECT … <complete your SQL query here> …)
-- where X is the correct index [1, …,10].
-- You can create intermediate views (as needed). Remember to drop these views after you have populated the result tables query1, query2, ...
-- You can use the "\i a2.sql" command in psql to execute the SQL commands in this file.
-- Good Luck!


-- *************************** Query 1 statements ****************************

INSERT INTO query1
SELECT pname, cname, tname
FROM champion ch JOIN tournament t ON ch.tid=t.tid
                 JOIN player p ON p.pid=ch.pid
                 JOIN country c ON p.cid=c.cid
WHERE t.cid=p.cid
ORDER BY pname ASC;



-- *************************** Query 2 statements *****************************

CREATE VIEW tnameANDtotalCapacity AS
SELECT tname, SUM(capacity) AS totalCapacity
FROM tournament t, court c
WHERE t.tid=c.tid
GROUP BY tname;

CREATE VIEW maxcapacity AS
SELECT MAX(totalcapacity)
FROM tnameandtotalcapacity;

INSERT INTO query2
  SELECT tname, max AS totalCapacity
  FROM tnameandtotalcapacity t, maxcapacity maxc
  WHERE t.totalcapacity=maxc.max
  ORDER BY tname ASC;

DROP VIEW maxcapacity;
DROP VIEW tnameANDtotalCapacity;



-- *************************** Query 3 statements *****************************

CREATE VIEW AllEventPlayers AS
SELECT winid, lossid
FROM event
  UNION ALL
SELECT lossid winid, winid lossid
FROM event;

CREATE VIEW p1info AS
SELECT pid p1id, pname p1name, globalrank p1globalrank, row_number()
OVER (order by (SELECT NULL)) AS rownum1
FROM player p, alleventplayers aep
WHERE p.pid=aep.winid;

CREATE VIEW p2info AS
SELECT pid p2id, pname p2name, globalrank p2globalrank, row_number()
OVER (order by (SELECT NULL)) AS rownum2
FROM player p, alleventplayers aep
WHERE p.pid=aep.lossid;

CREATE VIEW allinfo AS
SELECT *
FROM p1info p1, p2info p2
WHERE p1.rownum1=p2.rownum2;

INSERT INTO query3
  SELECT DISTINCT ai.p1id, ai.p1name, ai.p2id, ai.p2name
  FROM
    (SELECT p1id, MIN(allinfo.p2globalrank) AS min
    FROM allinfo group by p1id) temp JOIN allinfo ai ON ai.p1id=temp.p1id
         AND ai.p2globalrank=temp.min
  ORDER BY p1name ASC;

DROP VIEW allinfo;
DROP VIEW p2info;
DROP VIEW p1info;
DROP VIEW AllEventPlayers;



-- *************************** Query 4 statements *****************************

CREATE VIEW AllTournamentChampPairs AS
SELECT pid, tid
FROM player p, tournament t;

CREATE VIEW AllChampsOfTourns AS
SELECT pid, tid
FROM champion c;

CREATE VIEW NonExistingChampsOfTourns AS
(SELECT * FROM allTournamentChampPairs)
  EXCEPT
(SELECT * FROM AllChampsOfTourns);

CREATE VIEW ChampAtEveryTourn AS
(SELECT pid FROM player)
  EXCEPT
(SELECT pid FROM NonExistingChampsOfTourns);

INSERT INTO query4
  SELECT pid, pname
  FROM player
  WHERE pid IN (SELECT * FROM ChampAtEveryTourn)
  ORDER BY pname ASC;

DROP VIEW ChampAtEveryTourn;
DROP VIEW NonExistingChampsOfTourns;
DROP VIEW AllChampsOfTourns;
DROP VIEW AllTournamentChampPairs;



-- *************************** Query 5 statements *****************************

CREATE VIEW InfoOfTop10AvgWins AS
SELECT pid, AVG(wins) AS avgwins
FROM record
WHERE year >= 2011 AND year <= 2014
GROUP BY pid
ORDER BY avgwins DESC
LIMIT 10;

INSERT INTO query5
  SELECT p.pid, p.pname, t10.avgwins
  FROM player p, InfoOfTop10AvgWins t10
  WHERE p.pid=t10.pid
  ORDER BY avgwins DESC;

DROP VIEW InfoOfTop10AvgWins;



-- *************************** Query 6 statements *****************************

CREATE VIEW winsin2011 AS
SELECT pid, wins wins2011
FROM record
WHERE year=2011;

CREATE VIEW winsin2012 AS
SELECT pid, wins wins2012
FROM record
WHERE year=2012;

CREATE VIEW winsin2013 AS
SELECT pid, wins wins2013
FROM record
WHERE year=2013;

CREATE VIEW winsin2014 AS
SELECT pid, wins wins2014
FROM record
WHERE year=2014;

CREATE VIEW allinfo AS
SELECT w11.pid, wins2011, wins2012, wins2013, wins2014
FROM winsin2011 w11 JOIN winsin2012 w12 ON w11.pid=w12.pid
                    JOIN winsin2013 w13 ON w12.pid=w13.pid
                    JOIN winsin2014 w14 ON w13.pid=w14.pid;

CREATE VIEW playerswithwinsalwaysincreasing AS
SELECT pid
FROM allinfo
WHERE wins2011 < wins2012 AND
      wins2012 < wins2013 AND
      wins2013 < wins2014;

INSERT INTO query6
  SELECT p.pid, pname
  FROM player p JOIN playerswithwinsalwaysincreasing pwwai ON p.pid=pwwai.pid
  ORDER BY pname ASC;

DROP VIEW playerswithwinsalwaysincreasing;
DROP VIEW allinfo;
DROP VIEW winsin2014;
DROP VIEW winsin2013;
DROP VIEW winsin2012;
DROP VIEW winsin2011;



-- *************************** Query 7 statements *****************************

CREATE VIEW champstwiceinayear AS
SELECT pid, year
FROM champion
GROUP BY pid, year
HAVING COUNT(tid) > 1;

INSERT INTO query7
  SELECT pname, year
  FROM player p JOIN champstwiceinayear ch2y ON p.pid=ch2y.pid
  ORDER BY pname DESC, year DESC;

DROP VIEW champstwiceinayear;



-- *************************** Query 8 statements *****************************

CREATE VIEW player1info AS
SELECT winid, row1, p.p1name, cname c1name FROM
  (SELECT winid, row_number() OVER (ORDER BY (SELECT NULL)) row1
  FROM event) p1info JOIN (SELECT pid, pname p1name, cid FROM player) p
              ON p1info.winid=p.pid JOIN country c ON p.cid=c.cid;

CREATE VIEW player2info AS SELECT lossid, row2, p.p2name, cname c2name
FROM
  (SELECT lossid, row_number() OVER (ORDER BY (SELECT NULL)) row2
  FROM event) p2info JOIN (SELECT pid, pname p2name, cid FROM player) p
              ON p2info.lossid=p.pid JOIN country c ON p.cid=c.cid;

CREATE VIEW allinfo AS SELECT * FROM player1info t1 JOIN player2info t2
              ON t1.row1=t2.row2;

CREATE VIEW side1 AS
SELECT p1name, p2name, c1name cname
FROM allinfo
WHERE c1name=c2name;

CREATE VIEW side2 AS
SELECT p2name, p1name, c1name cname
FROM allinfo
WHERE c1name=c2name;

INSERT INTO query8
  SELECT *
  FROM side1
    UNION
  SELECT *
  FROM side2
  ORDER BY cname ASC, p1name DESC;

DROP VIEW side2;
DROP VIEW side1;
DROP VIEW allinfo;
DROP VIEW player2info;
DROP VIEW player1info;


-- *************************** Query 9 statements *****************************

CREATE VIEW allinfo AS
SELECT *
FROM champion ch JOIN (SELECT pid ppid, cid FROM player) p ON ch.pid=p.ppid;

CREATE VIEW champcounts AS
SELECT cid, count(cid) AS championcount
FROM allinfo
GROUP BY cid;

CREATE VIEW maxchamps AS
SELECT *
FROM champcounts
WHERE championcount = (SELECT MAX(championcount) max FROM champcounts);

INSERT INTO query9
  SELECT cname, championcount champions
  FROM country c JOIN maxchamps mc ON c.cid=mc.cid
  ORDER BY cname DESC;

DROP VIEW maxchamps;
DROP VIEW champcounts;
DROP VIEW allinfo;



-- **************************** Query 10 statements ****************************

CREATE VIEW winnerswithavgdurationover200 AS
SELECT winid p1id, AVG(duration) avgDuration
FROM event
GROUP BY winid
HAVING AVG(duration) > 200;

CREATE VIEW matchups AS
SELECT p1id, lossid p2id, avgduration
FROM event e JOIN winnerswithavgdurationover200 wwado200 ON
     e.winid=wwado200.p1id;

CREATE VIEW allinfo AS
SELECT DISTINCT *
FROM event e JOIN matchups m ON e.winid=m.p1id AND
     e.lossid=m.p2id AND year=2014;

CREATE VIEW wincount AS
SELECT p1id, COUNT(winid) numWins
FROM allinfo
WHERE winid=p1id
GROUP BY p1id;

CREATE VIEW losscount AS
SELECT p2id loser, COUNT(lossid) numLoss
FROM allinfo
WHERE lossid=p2id
GROUP BY p2id;

CREATE VIEW relevantinfo AS
SELECT *
FROM wincount w LEFT OUTER JOIN losscount l ON w.p1id=l.loser;

CREATE VIEW candidates AS
SELECT *
FROM relevantinfo
WHERE numwins > numloss OR numloss IS NULL;

INSERT INTO query10
  SELECT pname
  FROM player p JOIN candidates c ON p.pid=c.p1id
  ORDER BY pname DESC;

DROP VIEW candidates;
DROP VIEW relevantinfo;
DROP VIEW losscount;
DROP VIEW wincount;
DROP VIEW allinfo;
DROP VIEW matchups;
DROP VIEW winnerswithavgdurationover200;
