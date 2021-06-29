-- -- adding data to database

INSERT INTO Branches(bname) VALUES 
('Viborg'), ('Aarhus'), ('Aalborg'), ('Holding'), ('Vejle'),
('Fredericia'), ('Slagelse'), ('Kalundborg'), ('Roskilde'), ('Odense');

INSERT INTO Employees(branchId, eName, employmentDate) VALUES
(1, 'Elena', '2000/01/31'), (1, 'Maria', '2000/05/01'),
(3, 'Jens', '2010/05/31'), (9, 'Jan', '2010/09/15'),
(9, 'Johanne', '2010/12/01'), (10, 'Melissa', '2010/12/01'),
(3, 'Martin', '2011/03/31'), (8, 'Dennis', '2012/10/01'),
(8, 'Marianne', '2012/10/01'), (1, 'Michael', '2015/01/31');

INSERT INTO ProductCategories (pcName) VALUES
('book'), ('boardGame'), ('puzzle'), ('magnet'), ('keytag'),
('bookEnd'), ('bookMark'), ('bracelet');

INSERT INTO PropertyNames (prName) VALUES
('author'), ('publishYear'), ('minAge'), ('nrOfPieces'), ('color'),
('material');

INSERT INTO PropertyValues (val) VALUES
('George RR Martin'), ('JK Rowling'), ('Isaac Asimov'), ('2000'), ('2005'),
('2012'), ('5'), ('7'), ('12'), ('1000'), ('1500'), ('2500'), ('red'), 
('white'), ('blue'), ('green'), ('leather'), ('plastic'), ('metal');

INSERT INTO Products (pName, price, categoryId) VALUES
('Game of Thrones', 150.50, 1), ('Harry Potter', 170.90, 1),
('Foundation', )