 -- Part 1

CREATE DATABASE Gamestore;

USE Gamestore;

CREATE TABLE store_location (
	id INT PRIMARY KEY IDENTITY(1,1),
	name TEXT
);

CREATE TABLE items (
	id INT PRIMARY KEY IDENTITY(1,1),
	name TEXT,
	publishing_year INT
);

CREATE TABLE physical_items (
	id INT PRIMARY KEY IDENTITY(1,1),
	itemID INT FOREIGN KEY REFERENCES items(id),
	locationID INT FOREIGN KEY REFERENCES store_location(id)
);

INSERT INTO items (name, publishing_year) VALUES
('Red Dead Redemption 2', 2018),
('Marvels Spiderman', 2018),
('Portal', 2007);

INSERT INTO store_location (name) VALUES
('Aalborg'),
('Viborg'),
('København');

 -- constraint: shops don't sell games published before year 2000
ALTER TABLE items
ADD CHECK (publishing_year >= 2000)

INSERT INTO physical_items (itemID, locationID) VALUES
(1, 1),
(1, 3),
(2, 2),
(2, 3),
(3, 1),
(3, 2);

ALTER TABLE physical_items
ADD amount INT 

UPDATE physical_items 
SET amount = 2
WHERE id = 1

UPDATE physical_items 
SET amount = 5
WHERE id = 2

UPDATE physical_items 
SET amount = 3
WHERE id = 3

UPDATE physical_items 
SET amount = 5
WHERE id = 4

UPDATE physical_items 
SET amount = 4
WHERE id = 5

UPDATE physical_items 
SET amount = 2
WHERE id = 6

 -- show the number of 'Red Dead Redemption 2' games in storage in all shops
SELECT SUM(amount) AS RDR2_Total FROM physical_items WHERE itemID = (
SELECT id FROM items WHERE name LIKE 'Red Dead Redemption 2');



 -- Part 2

ALTER TABLE store_location
ADD earnings INT;

 -- '=' operator doesn't work between 'text' and 'varchar' data types
UPDATE store_location SET earnings = 65000 WHERE name LIKE 'Aalborg';
UPDATE store_location SET earnings = 83000 WHERE name LIKE 'Viborg';
UPDATE store_location SET earnings = 27000 WHERE name LIKE 'København';


-- the shop with the biggest earnings

-- approach 1: not working due to GROUP BY not allowing 'text' data type

--SELECT name AS Max_Income, MAX(earnings) 
--FROM store_location
--GROUP BY name;

 -- approach 2
SELECT name AS Max_Income FROM store_location
WHERE earnings = (SELECT MAX(earnings) FROM store_location);



SELECT name, earnings FROM store_location;

SELECT name, earnings FROM store_location
WHERE earnings > 50000;

SELECT * FROM physical_items WHERE locationID = 1

SELECT items.name FROM items
INNER JOIN physical_items ON physical_items.itemID = items.id
WHERE locationID = 1;

 -- how many of each game are in storage in Aalborg
SELECT items.name, physical_items.amount FROM items
INNER JOIN physical_items ON physical_items.itemID = items.id
WHERE locationID = 1;




select * from items
select * from store_location
select * from physical_items

