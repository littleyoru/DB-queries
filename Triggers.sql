-- Triggers

-- create database to use

CREATE DATABASE Bookstore;

USE Bookstore;

CREATE TABLE Books (
	id INT PRIMARY KEY IDENTITY(1, 1),
	bookName NVARCHAR(50) NOT NULL,
	author NVARCHAR(30) NOT NULL,
	publishYear INT NULL
);

CREATE TABLE Stores (
	id INT PRIMARY KEY IDENTITY(1, 1),
	storeName NVARCHAR(20) NOT NULL,
	earnings INT NULL
);

CREATE TABLE BookStorage (
	shopId INT FOREIGN KEY REFERENCES Stores(id) NOT NULL,
	bookId INT FOREIGN KEY REFERENCES Books(id) NOT NULL,
	amount INT NULL,
	CONSTRAINT PK_BookStorage PRIMARY KEY (shopId, bookId)
);



-- trigger 1: every time there's a new book, add a fixed number of 
-- them to each shop


-- stored procedure to add a new book to storage table for each 
-- shop based on book id

CREATE PROCEDURE putBookInStorage @bookid INT, @bookNr INT
AS
	INSERT INTO BookStorage(shopId, bookId, amount) 
	SELECT id, @bookid, @bookNr
	FROM Stores
GO



-- trigger 1 to call the stored procedure to add book to storage

-- CURSOR version -- the slowest method
CREATE TRIGGER addToStorage
ON Books
AFTER INSERT
AS
	DECLARE @idField INT
	DECLARE cur CURSOR READ_ONLY FOR 
		SELECT id FROM INSERTED
	OPEN cur
	FETCH NEXT FROM cur
	INTO @idField
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC putBookInStorage @idField, 5
		FETCH NEXT FROM cur
		INTO @idField
	END
CLOSE cur
DEALLOCATE cur




-- dynamic query version -- fast but not finished (syntax problems)
CREATE TRIGGER addToStorage
ON Books
AFTER INSERT
AS
DECLARE @par NVARCHAR(MAX)
SELECT @par = @par + 'EXEC putBookInStorage ' + LTRIM(id) + ', ' + 5
FROM INSERTED;
EXEC(@PAR);



-- test trigger 1

INSERT INTO Stores(storeName) VALUES
('Viborg'),
('Aalborg'),
('Aarhus');

INSERT INTO Books(bookName, author, publishYear) VALUES
('Game of Thrones', 'George RR Martin', 1996),
('Hamlet', 'William Shakespeare', 1600),
('Foundation', 'Isaac Asimov', 1951)





-- trigger 2: on book sold (amount in shop storage changed), add
-- amountInMinus*bookCost to existing earnings


 -- SET-BASED UPDATE version (recommended) - not fully working
 -- can't use DELETED.amount and INSERTED.amount in SET due to ambiguity
 -- (can refer to amount from different rows, before rest of query)
 -- removing DELETED.amount and INSERTED.amount works, but only
 -- updates once for each shopId found in SELECT query result, even if
 -- they can appear multiple times due to amount being changed for 
 -- different books in same shop

CREATE TRIGGER SellBook
ON BookStorage
AFTER UPDATE
AS
	UPDATE Stores SET earnings += (50 * (DELETED.amount - INSERTED.amount))
	WHERE id IN (
		SELECT (CASE  
			WHEN i.amount < d.amount 
				THEN i.shopid 
				ELSE 0
			END)
		FROM INSERTED i
		INNER JOIN DELETED d
		ON i.shopId = d.shopId AND i.bookId = d.bookId
		)



 -- CTE table approach
 -- error with accessing CTE table fields in update

CREATE TRIGGER SellBook
ON BookStorage
AFTER UPDATE
AS
	WITH Temp_CTE (shopId, minusAmount)
	AS
	(
	SELECT i.shopId, (d.amount - i.amount) AS minusAmount
		FROM INSERTED i
		INNER JOIN DELETED d
		ON i.shopId = d.shopId AND i.bookId = d.bookId
		WHERE d.amount > i.amount
	)
	UPDATE Stores SET earning += (50 * Temp_CTE.minusAmount)
	WHERE Stores.id = Temp_CTE.shopId





-- test trigger to see INSERTED and DELETED temp tables records

CREATE TRIGGER SellBookTest1
ON BookStorage
AFTER UPDATE
AS
	SELECT i.ShopId, (d.amount - i.amount) AS minusAmount 
	FROM INSERTED i
	INNER JOIN DELETED d
	ON i.shopId = d.shopId AND i.bookId = d.bookId
	WHERE d.amount > i.amount




 -- another CTE table approach
 -- works, but only if different books don't get update at the same time

CREATE TRIGGER SellBookTest
ON BookStorage
AFTER UPDATE
AS
	WITH Temp_cte (shopId, minusAmount)
	AS
	(
	SELECT i.ShopId, (d.amount - i.amount) AS minusAmount 
	FROM INSERTED i
	INNER JOIN DELETED d
	ON i.shopId = d.shopId AND i.bookId = d.bookId
	WHERE d.amount > i.amount
	)
	UPDATE Stores SET earnings += (50 * Temp_cte.minusAmount)
	FROM Stores
	INNER JOIN Temp_cte ON Stores.id = Temp_cte.shopId






select * from Stores
select * from Books
select * from BookStorage

update BookStorage set amount = 5 where shopId = 2
update Stores set earnings = 0

update BookStorage set amount = 3 where shopId = 3