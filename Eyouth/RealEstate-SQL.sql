-- 1-Number of listed properties by type and location
USE RealEstate
SELECT PropertyType, Location, COUNT(*) AS number_of_property
FROM Properties
GROUP BY PropertyType, Location
ORDER BY 3 DESC;


--2-Average price per square meter per city
USE RealEstate;
SELECT Location, PropertyType, AVG(CAST(PriceUSD AS FLOAT) / CAST(Size_sqm AS FLOAT)) AS Avg_price
FROM Properties
GROUP BY Location, PropertyType
ORDER BY 1 DESC;


--3-Distribution of property types (Apartment, Villa, etc.)
USE RealEstate
SELECT PropertyType, COUNT(*) AS number
FROM Properties
GROUP BY PropertyType
ORDER BY number DESC;


--4-Top 10 most expensive or most visited properties

--Top 10 most expensive properties
USE RealEstate;
SELECT TOP 10 PropertyID, PropertyType, Location, PriceUSD
FROM Properties
ORDER BY PriceUSD DESC;

--Top 10 most Visited properties
SELECT TOP 10 p.PropertyID, p.PropertyType, COUNT(v.VisitID) AS Total_Visited
FROM Properties p
JOIN Visits v 
ON p.PropertyID = v.PropertyID
GROUP BY p.PropertyID,p.PropertyType
ORDER BY 3 DESC;

--5-Total sales value over time (monthly, quarterly, yearly)

USE RealEstate
-- Monthly Sales
SELECT
    MONTH(SaleDate) AS month,
    SUM(CAST(SalePrice AS FLOAT)) AS total_sales_value,
    COUNT(*) AS number_of_sales
FROM
    Sales
GROUP BY
     MONTH(SaleDate)
ORDER BY
     month DESC;

 -- Yearly Sales

SELECT
YEAR(SaleDate) AS year,
SUM(CAST(SalePrice AS FLOAT)) AS total_sales_value,
COUNT(*) AS number_of_sales
FROM
    Sales
GROUP BY
     YEAR(SaleDate)
ORDER BY
     year DESC;

-- Quarter Sales (By abdelghany)
	 SELECT
    CONCAT(YEAR(SaleDate), '-Q', DATEPART(quarter, SaleDate)) AS SaleQuarter,
    SUM(CAST(SalePrice AS FLOAT)) AS TotalQuarterlySales
FROM
    Sales
GROUP BY
    CONCAT(YEAR(SaleDate), '-Q', DATEPART(quarter, SaleDate))
ORDER BY
    SaleQuarter;


--6-Average sale value per property type 
USE RealEstate
SELECT p.PropertyType, year(s.SaleDate) AS Year , ROUND(AVG(CAST(s.SalePrice AS FLOAT)),1) AS Average_sales, p.Location,
(s.SalePrice - p.PriceUSD) AS profit
FROM Sales s
JOIN Properties p
ON p.PropertyID = s.PropertyID
GROUP BY p.PropertyType, (s.SalePrice - p.PriceUSD) , year (s.SaleDate), p.Location
ORDER BY profit DESC;


--7-Conversion Rate per Property or Agent
USE RealEstate;
-----Conversion Rate per Property
SELECT 
    p.PropertyID,
    p.Location,
    COUNT(DISTINCT v.VisitID) AS TotalVisits,
    COUNT(DISTINCT s.SaleID) AS TotalSales,
    CASE 
        WHEN COUNT(DISTINCT v.VisitID) > 0 
        THEN CAST(COUNT(DISTINCT s.SaleID) AS FLOAT) / COUNT(DISTINCT v.VisitID) 
        ELSE 0 
    END AS ConversionRate
FROM 
    Properties p
LEFT JOIN 
    Visits v ON p.PropertyID = v.PropertyID
LEFT JOIN 
    Sales s ON p.PropertyID = s.PropertyID
GROUP BY 
    p.PropertyID, p.Location
ORDER BY 
    ConversionRate DESC;


-----Conversion Rate per Agent
SELECT 
    A.AgentID,
    A.FirstName,
    A.LastName,
    COUNT(DISTINCT S.SaleID) AS TotalSales,
    COUNT(DISTINCT V.VisitID) AS TotalVisits,
    CASE 
        WHEN COUNT(DISTINCT V.VisitID) = 0 THEN 0
        ELSE ROUND(CAST(COUNT(DISTINCT S.SaleID) AS FLOAT) / COUNT(DISTINCT V.VisitID),3) * 100
    END AS ConversionRatePercentage
FROM Agents A
LEFT JOIN Sales S ON A.AgentID = S.AgentID
LEFT JOIN Visits V ON A.AgentID = V.AgentID
GROUP BY A.AgentID, A.FirstName, A.LastName
ORDER BY ConversionRatePercentage DESC;

--8 Time on market before sale
USE RealEstate
SELECT s.PropertyID, s.SaleDate,
    DATEDIFF(DAY, MIN(v.VisitDate), s.SaleDate) AS "Days On Marke"
FROM  Sales s
JOIN  Visits v ON s.PropertyID = v.PropertyID
WHERE  v.VisitDate <= s.SaleDate       
GROUP BY s.PropertyID, s.SaleDate
ORDER BY 3;

--9-Number of sales per agent
USE RealEstate
SELECT a.AgentID, COUNT(*) AS number_of_sales
FROM Sales s
JOIN Agents a 
ON a.AgentID = s.AgentID
GROUP BY a.AgentID
ORDER BY 2 DESC;

--10-Number of client visits per agent
USE RealEstate
SELECT 
    a.AgentID,
    a.FirstName, a.LastName,
    COUNT(v.VisitID) AS NumberOfClientVisits
FROM 
    Agents a
 JOIN 
    Visits v ON a.AgentID = v.AgentID
GROUP BY 
    a.AgentID, a.FirstName, a.LastName
ORDER BY 
    NumberOfClientVisits DESC;

--11-Avg sale value handled by each agent
USE RealEstate;
SELECT
    a.AgentID,
    a.FirstName,
    COUNT(s.SaleID) AS NumberOfSales,
    SUM(CAST(s.SalePrice AS FLOAT)) AS TotalSalesValue,
    AVG(CAST(s.SalePrice AS FLOAT)) AS AverageSaleValue,
    CONCAT('$', FORMAT(AVG(CAST(s.SalePrice AS FLOAT)), 'N0')) AS FormattedAvgValue
FROM
    Agents a
LEFT JOIN
    Sales s ON a.AgentID = s.AgentID
GROUP BY
    a.AgentID, a.FirstName
ORDER BY
    AverageSaleValue DESC;


--12-Number of properties visited per client
USE RealEstate;
SELECT c.ClientID, c.FirstName + ' ' + c.LastName AS full_name, p.PropertyType, 
COUNT(*) AS number_of_properties_visited, v.VisitDate
FROM Visits v
JOIN Clients c
ON c.ClientID = v.ClientID
JOIN Properties p
ON p.PropertyID= v.PropertyID
GROUP BY c.ClientID, p.PropertyType, c.FirstName,  c.LastName, v.VisitDate
ORDER BY full_name, v.VisitDate, number_of_properties_visited DESC;


--13- Top And Lowest clients by sale value

USE RealEstate;
SELECT TOP 10  --- TOP 10 CLINTS
    c.ClientID,
    CONCAT(c.FirstName, ' ', c.LastName) AS client_name,
    COUNT(DISTINCT s.PropertyID) AS properties_purchased,
    SUM(CAST(s.SalePrice AS FLOAT)) AS total_spend,
    MAX(CAST(s.SalePrice AS FLOAT)) AS highest_purchased_property,
	    MAX(s.SaleDate) AS most_recent_purchase
FROM
    Sales s
JOIN
    Clients c ON s.ClientID = c.ClientID
GROUP BY
    c.ClientID,
    c.FirstName,
    c.LastName
ORDER BY
    total_spend DESC;

	--  LOWEST 10  CLINTS
SELECT TOP 10
    c.ClientID,
    CONCAT(c.FirstName, ' ', c.LastName) AS client_name,
    COUNT(DISTINCT s.PropertyID) AS properties_purchased,
    SUM(CAST(s.SalePrice AS FLOAT)) AS total_spend,
    MAX(CAST(s.SalePrice AS FLOAT)) AS highest_purchased_property,
	    MAX(s.SaleDate) AS most_recent_purchase
FROM
    Sales s
JOIN
    Clients c ON s.ClientID = c.ClientID
GROUP BY
    c.ClientID,
    c.FirstName,
    c.LastName
ORDER BY
    total_spend ASC;


--14-First-time vs repeat buyers
USE RealEstate;

SELECT
    c.ClientID,
    CONCAT(c.FirstName, ' ', c.LastName) AS client_name,
    COUNT(s.SaleID) AS purchase_count,
    CASE
        WHEN COUNT(s.SaleID) = 1 THEN 'First-time Buyer'
        ELSE 'Repeat Buyer'
    END AS buyer_type,
    SUM(CAST(s.SalePrice AS FLOAT)) AS total_spend,
    MAX(s.SaleDate) AS last_purchase_date
FROM
    clients c
JOIN
    sales s ON c.ClientID = s.ClientID
GROUP BY
    c.ClientID, c.FirstName, c.LastName
ORDER BY
    purchase_count DESC;



 -- Count First time Buyers

	SELECT COUNT(*) AS FirstTime_Buyer_Count
FROM (
    SELECT ClientID, COUNT(*) AS SaleCount
    FROM Sales
    GROUP BY ClientID) AS ClientSales
WHERE SaleCount =1;                 -- HOW MANY CLIENTS MADE ONLY ONE SALE
   -- Count Repeat Buyers
SELECT COUNT(*) AS Repeated_buyer
FROM (
    SELECT ClientID, COUNT(*) AS SaleCount
    FROM Sales
    GROUP BY ClientID
) AS ClientSales
WHERE SaleCount > 1;


--15-Region-based client interest (visits by city)
USE RealEstate;

---  عدد الزيارات لكل مدينة
SELECT 
    p.Location,
    COUNT(v.VisitID) AS total_visits,
    COUNT(DISTINCT v.ClientID) AS unique_clients,
    ROUND(COUNT(v.VisitID) * 100.0 / (SELECT COUNT(*) FROM visits), 2) AS visit_percentage
FROM 
    visits v
JOIN 
    properties p ON v.PropertyID = p.PropertyID
GROUP BY 
    p.Location
ORDER BY 
    total_visits DESC;

	---توزيع الزيارات حسب المدينة ونوع العقار
SELECT  
    p.Location,
    p.PropertyType,
    COUNT(v.VisitID) AS visit_count
FROM 
    visits v
JOIN 
    properties p ON v.PropertyID = p.PropertyID
GROUP BY 
    p.Location, p.PropertyType
ORDER BY 
    p.Location, visit_count DESC;

	---مدن بأعلى معدل تحويل من الزيارات إلى مبيعات
	SELECT 
    p.Location,
    COUNT(DISTINCT v.VisitID) AS total_visits,
    COUNT(DISTINCT s.SaleID) AS total_sales,
    ROUND(COUNT(DISTINCT s.SaleID) * 100.0 / COUNT(DISTINCT v.VisitID), 2) AS conversion_rate
FROM 
    visits v
JOIN 
    properties p ON v.PropertyID = p.PropertyID
LEFT JOIN 
    sales s ON v.PropertyID = s.PropertyID 
GROUP BY 
    p.Location
HAVING 
    COUNT(DISTINCT v.VisitID) > 10  -- فقط المدن التي لديها أكثر من 10 زيارات
ORDER BY 
    conversion_rate DESC;


--16- Sales heatmap by city or region
USE RealEstate;

SELECT
    p.Location,
    COUNT(s.SaleID) AS total_sales,
    SUM(CAST(s.SaleID AS FLOAT)) AS total_volume,
    ROUND(AVG(CAST(s.SalePrice AS FLOAT)), 2) AS avg_sale_price,
    COUNT(DISTINCT s.ClientID) AS unique_buyers
FROM
    sales s
JOIN
    properties p ON s.PropertyID = p.PropertyID

GROUP BY
    p.Location
ORDER BY
    total_volume DESC;



--17 High-performing areas (most sold or highest priced)
USE RealEstate;
SELECT
    p.Location,
  COUNT(s.SaleID) AS total_sales,
 ROUND(SUM(CAST(PriceUSD AS FLOAT)),2) AS Highest_Price,
 SUM(CAST(s.SalePrice AS FLOAT)) AS total_sales_volume 


FROM
    Sales s
JOIN
    properties p ON s.PropertyID = p.PropertyID
GROUP BY
    p.Location
ORDER BY
    total_sales DESC;


--18-Average visit-to-sale ratio per location
USE RealEstate;

SELECT
    P.Location,
    CAST(COUNT(DISTINCT V.VisitID) AS DECIMAL(10, 2)) AS TotalVisits,
    CAST(COUNT(DISTINCT S.SaleID) AS DECIMAL(10, 2)) AS TotalSales,
    CASE
        WHEN COUNT(DISTINCT S.SaleID) > 0 THEN CAST(COUNT(DISTINCT V.VisitID) AS DECIMAL(10, 2)) / COUNT(DISTINCT S.SaleID)
        ELSE NULL
    END AS AverageVisitsPerSale
FROM
    Properties P
LEFT JOIN
    Visits V ON P.PropertyID = V.PropertyID
LEFT JOIN
    Sales S ON P.PropertyID = S.PropertyID
GROUP BY
    P.Location
ORDER BY
    AverageVisitsPerSale DESC ;




