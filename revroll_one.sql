/** Question 1
Installers receive performance based year end bonuses. 
Bonuses are calculated by taking 10% of the total value of parts installed by the installer.

Calculate the bonus earned by each installer rounded to a whole number. 
Sort the result by bonus in increasing order.*/

SELECT 
	i.name 
  , ROUND(0.1*SUM(p.price*o.quantity), 0) AS bonus
FROM installers i 
LEFT JOIN installs ins ON i.installer_id = ins.installer_id 
LEFT JOIN orders o ON ins.order_id=o.order_id
LEFT JOIN parts p ON p.part_id = o.part_id
GROUP BY i.name
ORDER BY 2;

--or with cte 
WITH CTE1 AS(
SELECT 
	o.order_id
  , o.quantity*p.price as order_revenue 
FROM orders o 
INNER JOIN parts p ON p.part_id=o.part_id
)
SELECT 
	i.name
  , ROUND(0.1*SUM(CTE1.order_revenue),0) as bonus
FROM installers i 
INNER JOIN installs ins ON i.installer_id = ins.installer_id 
INNER JOIN  CTE1 ON ins.order_id = CTE1.order_id
GROUP BY i.name 
ORDER BY 2;

/*question 2 
We need to calculate the scores of all installers after all matches.
Return the result table ordered by num_points in decreasing order. 
In case of a tie, order the records by installer_id in increasing order.
*/

WITH points_table AS(        
SELECT 
	installer_one_id as installer_id
  , 3 as points       
FROM install_derby
WHERE installer_one_time<installer_two_time
UNION ALL
SELECT 
	installer_two_id as installer_id
  , 3 as points      
FROM install_derby
WHERE installer_one_time>installer_two_time
UNION ALL 
SELECT 
  installer_one_id as installer_id     	
  , 1 as points      
FROM install_derby
   WHERE installer_one_time=installer_two_time
UNION ALL 
SELECT 
  installer_two_id as installer_id     	
  , 1 as points      
FROM install_derby
   WHERE installer_one_time=installer_two_time         
)
SELECT 
   i.installer_id
   , i.name 
   , SUM(COALESCE(p.points, 0)) as num_points
FROM installers i 
LEFT JOIN points_table p ON p.installer_id = i.installer_id
GROUP BY i.installer_id
   , i.name 
ORDER BY 3 DESC, 1 ASC; 

/*
Question #3: 
Write a query to find the fastest install time with its corresponding derby_id for each installer. 
In case of a tie, you should find the install with the smallest derby_id.
Return the result table ordered by installer_id in ascending order.
Expected column names: derby_id, installer_id, install_time
*/

WITH inst_time AS (
SELECT 
  derby_id
	,installer_one_id as installer_id
  , installer_one_time as install_time
FROM install_derby
UNION ALL 
SELECT 
  derby_id
	,installer_two_id as installer_id
  , installer_two_time as install_time
FROM install_derby
),
ordered_table AS(
SELECT 
	*
  , ROW_NUMBER() OVER(PARTITION BY installer_id ORDER BY install_time, derby_id) as rows 
FROM inst_time 
)
SELECT 
	derby_id
  , installer_id
  , install_time
FROM ordered_table
WHERE rows = 1;


/*
Question #4: 
Write a solution to calculate the total parts spending by customers 
paying for installs on each Friday of every week in November 2023.
If there are no purchases on the Friday of a particular week, the parts total should be set to 0.

Return the result table ordered by week of month in ascending order.
*/

WITH fridays AS(
SELECT 
	 install_date as november_fridays
  , order_id
FROM installs
WHERE 1=1
	AND EXTRACT (dow from install_date) = 5
  AND EXTRACT(YEAR from install_date) =2023
  AND EXTRACT(MONTH from install_date) =11
) 
SElECT 
	f.november_fridays
  , SUM(COALESCE (o.quantity*p.price, 0)) as parts_total
FROM fridays f
LEFT JOIN orders o ON o.order_id=f.order_id
LEFT JOIN parts p ON p.part_id = o.part_id
GROUP BY f.november_fridays;

--or 
SELECT 
	i.install_date
 , SUM(COALESCE(o.quantity*p.price,0)) as parts_total
FROM installs i
LEFT JOIN orders o ON i.order_id=o.order_id
LEFT JOIN parts p ON p.part_id = o.part_id
WHERE 1=1
	AND EXTRACT (dow from i.install_date) = 5
  AND EXTRACT(YEAR from i.install_date) =2023
  AND EXTRACT(MONTH from i.install_date) =11
GROUP BY i.install_date
ORDER BY 1;


