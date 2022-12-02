/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: 1O
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT DISTINCT name 
FROM Facilities 
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(DISTINCT name) 
FROM Facilities 
WHERE membercost > 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT DISTINCT facid, name, membercost, monthlymaintenance 
FROM Facilities 
WHERE membercost > 0 AND (membercost / monthlymaintenance) < .2;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * 
FROM Facilities WHERE facid IN ('1', '5');

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT DISTINCT name, monthlymaintenance, (CASE WHEN monthlymaintenance > 100 THEN 'Expensive' ELSE 'Cheap' END) AS Label
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT surname, firstname
FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members)
LIMIT 10;

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT name, CONCAT(firstname, ' ', surname) as fullname
FROM Bookings
	INNER JOIN Facilities 
    	ON Bookings.facid = Facilities.facid
    INNER JOIN Members
    	ON Bookings.memid = Members.memid
WHERE name IN ('Tennis Court 1', 'Tennis Court 2')
ORDER BY fullname;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT Facilities.name AS facility, CONCAT( Members.firstname,  ' ', Members.surname ) AS name, 
CASE WHEN Bookings.memid = 0
THEN Facilities.guestcost * Bookings.slots
ELSE Facilities.membercost * Bookings.slots
END AS finalcost
FROM Bookings
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
AND Bookings.starttime LIKE  '2012-09-14%'
AND (((Bookings.memid =0) AND (Facilities.guestcost * Bookings.slots >30))
OR ((Bookings.memid > 0) AND (Facilities.membercost * Bookings.slots >30)))
INNER JOIN Members ON Bookings.memid = Members.memid
ORDER BY finalcost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT * 
FROM ( 
    SELECT Facilities.name as facility, CONCAT(Members.firstname, ' ', Members.surname) as name,
    CASE WHEN Bookings.memid = 0
    THEN Facilities.guestcost * Bookings.slots
    ELSE Facilities.membercost * Bookings.slots
    END AS finalcost
   	FROM Bookings
    INNER JOIN Facilities ON Bookings.facid = Facilities.facid
    AND Bookings.starttime LIKE '2012-09-14%'
    INNER JOIN Members ON Bookings.memid = Members.memid) sub
WHERE finalcost > 30
ORDER BY finalcost DESC;

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
# SELECT facility, SUM(FINALCOST) as totalrev
# FROM(
#     SELECT FACILITIES.name as facility,
#     CASE WHEN BOOKINGS.memid = 0 
#         THEN FACILITIES.guestcost * BOOKINGS.slots
#         ELSE FACILITIES.membercost * BOOKINGS.slots
#         END AS finalcost
#         FROM BOOKINGS
#     INNER JOIN FACILITIES ON FACILITIES.facid = BOOKINGS.facid
#     INNER JOIN MEMBERS on MEMBERS.memid = BOOKINGS.memid) sub
# GROUP BY facility
# HAVING totalrev < 1000
# ORDER BY totalrev;


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
# WITH rec_by_list AS (SELECT memid, firstname AS rec_by_firstname, surname AS rec_by_surname FROM MEMBERS)
# SELECT MEMBERS.firstname, MEMBERS.surname, rec_by_list.rec_by_firstname, rec_by_list.rec_by_surname
# FROM MEMBERS
# LEFT JOIN rec_by_list ON MEMBERS.recommendedby = rec_by_list.memid
# ORDER BY surname, firstname


/* Q12: Find the facilities with their usage by member, but not guests */
# SELECT FACILITIES.name, COUNT(BOOKINGS.bookid) AS times_booked, MEMBERS.firstname, MEMBERS.surname
# FROM BOOKINGS
# INNER JOIN FACILITIES ON BOOKINGS.facid = FACILITIES.facid
# AND BOOKINGS.memid > 0
# INNER JOIN MEMBERS ON BOOKINGS.memid = MEMBERS.memid
# GROUP BY FACILITIES.name, MEMBERS.firstname, MEMBERS.surname;


/* Q13: Find the facilities usage by month, but not guests */
# SELECT FACILITIES.name, COUNT(BOOKINGS.bookid) AS times_booked, strftime('%m', BOOKINGS.starttime) as month
# FROM BOOKINGS
# INNER JOIN FACILITIES ON BOOKINGS.facid = FACILITIES.facid
# AND BOOKINGS.memid > 0
# GROUP BY FACILITIES.name, month;
