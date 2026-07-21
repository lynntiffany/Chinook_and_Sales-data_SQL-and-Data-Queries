CREATE DATABASE chinook;
USE chinook;

SHOW TABLES;

-- Check Row Counts
SELECT * FROM Album;
SELECT * FROM Artist;
SELECT * FROM Customer;
SELECT * FROM Employee;
SELECT * FROM Genre;
SELECT * FROM Invoice;
SELECT * FROM InvoiceLine;
SELECT * FROM MediaType;
SELECT * FROM Playlist;
SELECT * FROM PlaylistTrack;
SELECT * FROM Track;

DESCRIBE Album;
DESCRIBE Artist;
DESCRIBE Customer;
DESCRIBE Employee;
DESCRIBE Genre;
DESCRIBE Invoice;
DESCRIBE InvoiceLine;
DESCRIBE MediaType;
DESCRIBE Playlist;
DESCRIBE PlaylistTrack;
DESCRIBE Track;

-- Understand table relationships
-- Album and Artists
SELECT
    ar.Name AS Artist,
    al.Title AS Album
FROM Album al
JOIN Artist ar
ON al.ArtistId = ar.ArtistId
LIMIT 10;

-- customer and invoices
SELECT
    c.FirstName,
    c.LastName,
    i.InvoiceDate
FROM Customer c
JOIN Invoice i
ON c.CustomerId = i.CustomerId
LIMIT 10;

-- Invoice details
SELECT
    il.InvoiceLineId,
    t.Name,
    il.Quantity,
    il.UnitPrice
FROM InvoiceLine il
JOIN Track t
ON il.TrackId = t.TrackId
LIMIT 10;

-- SELECT/ WHERE/ ORDER BY
SELECT FirstName, LastName, Country
FROM customer;

-- Customers from Brazil
SELECT FirstName, LastName, Country
FROM Customer
WHERE Country = 'Brazil';

-- Tracks longer than 5 min
SELECT Name, Milliseconds
FROM Track
WHERE Milliseconds > 300000
ORDER BY  Milliseconds Desc;

-- Total sales by country
SELECT BillingCountry,
SUM(Total) AS TotalSales
FROM Invoice
GROUP BY BillingCountry;

-- Number of customers by country
SELECT Country,
COUNT(*) AS NumberOfCustomers
FROM Customer
GROUP BY Country;

-- Average track duration by genre
SELECT g.Name AS Genre, AVG(t.Milliseconds) AS AverageDuration
FROM Track t
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name;

-- Countries with more than one customer
SELECT Country,
COUNT(*) AS Customers
FROM Customer
GROUP BY Country
HAVING COUNT(*) > 1;

-- Countries with total sales above $100
SELECT BillingCountry, SUM(Total) AS Revenue
FROM Invoice
GROUP BY BillingCountry
HAVING SUM(Total) > 100;

-- Advanced Sql --
-- Inner Join to retrieve each customer's invoice details
SELECT
    c.FirstName,
    c.LastName,
    i.InvoiceId,
    i.InvoiceDate,
    i.Total
FROM Customer c
INNER JOIN Invoice i
ON c.CustomerId = i.CustomerId;

-- Left Join :Display all customers, including those who may not have made any purchases.
SELECT c.FirstName,c.LastName,i.InvoiceId
FROM Customer c
LEFT JOIN Invoice i
ON c.CustomerId = i.CustomerId;

-- Right Join
SELECT c.FirstName,c.LastName,i.InvoiceId
FROM Customer c
RIGHT JOIN Invoice i
ON c.CustomerId = i.CustomerId;

-- Subquery: Find customers whose total invoice amount is above the average invoice total.
SELECT CustomerId,Total
FROM Invoice
WHERE Total >
(
    SELECT AVG(Total)
    FROM Invoice
);

-- Assign a unique sequential number to invoices ordered by total.
SELECT
    InvoiceId,
    CustomerId,
    Total,
    ROW_NUMBER() OVER (ORDER BY Total DESC) AS RowNumber
FROM Invoice;

-- Rank invoices by total value.
SELECT
    InvoiceId,
    CustomerId,
    Total,
    RANK() OVER (ORDER BY Total DESC) AS InvoiceRank
FROM Invoice;

-- Rank invoices within each billing country.
SELECT
    BillingCountry,
    InvoiceId,
    Total,
    RANK() OVER
    (
        PARTITION BY BillingCountry
        ORDER BY Total DESC
    ) AS CountryRank
FROM Invoice;

-- Highest revenue generating tracks
SELECT
    t.Name AS TrackName,
    SUM(il.Quantity * il.UnitPrice) AS TotalRevenue
FROM InvoiceLine il
JOIN Track t
ON il.TrackId = t.TrackId
GROUP BY t.TrackId, t.Name
ORDER BY TotalRevenue DESC
LIMIT 10;

-- Top 10 spending customers
SELECT
    c.FirstName,
    c.LastName,
    SUM(i.Total) AS TotalSpent
FROM Customer c
JOIN Invoice i
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY TotalSpent DESC
LIMIT 10;

-- Revenue trend over time
SELECT
    YEAR(InvoiceDate) AS Year,
    MONTH(InvoiceDate) AS Month,
    SUM(Total) AS MonthlyRevenue
FROM Invoice
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY MonthlyRevenue DESC;

-- How many purchases has each customer made?
SELECT
    c.FirstName,
    c.LastName,
    COUNT(i.InvoiceId) AS NumberOfPurchases,
    SUM(i.Total) AS TotalSpent
FROM Customer c
JOIN Invoice i
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY TotalSpent DESC;

-- Create Indexes
CREATE INDEX idx_invoice_customer
ON Invoice(CustomerId);

CREATE INDEX idx_invoiceline_track
ON InvoiceLine(TrackId);

EXPLAIN
SELECT
    c.FirstName,
    c.LastName,
    SUM(i.Total)
FROM Customer c
JOIN Invoice i
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;