 -- global login needs to be created before user
CREATE LOGIN ElenaLogin WITH PASSWORD = '1234';


CREATE USER Elena FOR LOGIN ElenaLogin;



 -- logged in ElenaLogin

-- fail: can only create 1 user per login
CREATE USER Michael FOR LOGIN ElenaLogin;



 -- logged in MichaelLogin

CREATE LOGIN MichaelLogin WITH PASSWORD = '5678';
CREATE USER Michael FOR LOGIN MichaelLogin;


ALTER LOGIN MichaelLogin WITH PASSWORD = 'Password1';
ALTER LOGIN MichaelLogin WITH NAME = Guest1Login;


DROP USER Michael;
DROP LOGIN Guest1Login;


 -- 'ALL' is deprecated
GRANT ALL TO ElenaLogin;


 -- grant CREATE TABLE permission in Bookstore db to user Elena
USE Bookstore
GRANT CREATE TABLE TO Elena;



 -- show permissions for user Elena

SELECT sys.database_permissions.permission_name, 
	sys.database_permissions.type permissions_type,
	sys.database_permissions.state permission_state
FROM sys.database_permissions
JOIN sys.database_principals
ON sys.database_permissions.grantee_principal_id = sys.database_principals.principal_id
WHERE sys.database_principals.name = 'Elena'



 -- stored procedure to add login and user, create a database
 -- and give user full permission for the created database
 -- and give user read permission for the rest
 -- risk of sql injections.. problems with quotes!
CREATE PROCEDURE challenge @name NVARCHAR(30), @pass NVARCHAR(20)
AS
	DECLARE @loginstmt NVARCHAR(200);
	DECLARE @userstmt NVARCHAR(200);
	SET @loginstmt = 'CREATE LOGIN DBLogin WITH PASSWORD = ''' + @pass + ''''
	SET @userstmt = 'CREATE USER ' + @name + ' FOR LOGIN DBLogin;'
	EXEC (@loginstmt);
	EXEC (@userstmt);
	CREATE DATABASE TestDB;

	DECLARE @readRole NVARCHAR(200);
	SET @readRole = 'USE master; EXEC sp_addrolemember ''db_datareader'', '+ @name +''
	EXEC (@readRole)

	DECLARE @ownerRole NVARCHAR(200);
	SET @ownerRole = 'USE Stupidtest; EXEC sp_addrolemember ''db_owner'', '+ @name +''
	EXEC (@ownerRole)
GO


 --call stored procedure
EXEC challenge 'Michael','Password2'



 -- user not getting the right permissions.. can insert in other db
CREATE PROCEDURE challenge1 @name NVARCHAR(30), @pass NVARCHAR(20)
AS
	DECLARE @loginstmt NVARCHAR(200);
	DECLARE @userstmt NVARCHAR(200);
	SET @loginstmt = 'CREATE LOGIN DBLogin WITH PASSWORD = ''' + @pass + ''''
	SET @userstmt = 'CREATE USER ' + @name + ' FOR LOGIN DBLogin;'
	EXEC (@loginstmt);
	EXEC (@userstmt);
	--DECLARE @dbName NVARCHAR = 'TestDB';
	CREATE DATABASE TestDB;

	DECLARE @roleparam1 NVARCHAR(20) = 'db_datareader';
	DECLARE @readRole NVARCHAR(MAX);
	SET @readRole = N'USE master; EXEC sp_addrolemember @roleparam1, @name';
	EXEC sys.sp_executesql 
		@stmt = @readRole,
		@params = N'@roleparam1 NVARCHAR(20), @name NVARCHAR(30)',
		@roleparam1 = @roleparam1, @name = @name;

	DECLARE @roleparam2 NVARCHAR(20) = 'db_owner';
	DECLARE @ownerRole NVARCHAR(MAX);
	SET @ownerRole = N'EXEC sp_addrolemember @roleparam2, @name';
	DECLARE @usestmt NVARCHAR(MAX) = N'USE TestDB';
	EXEC sys.sp_executesql @stmt = @usestmt;
	EXEC sys.sp_executesql
		@stmt = @ownerRole,
		@params = N'@roleparam2 NVARCHAR(20), @name NVARCHAR(30)',
		@roleparam2 = @roleparam2, @name = @name;
GO

 -- call
EXEC challenge1 'Mike', 'Password3'



use Bookstore;
select * from Books

insert into Books(bookName, author, publishYear)
values ('Test Book', 'Test Author', 2000);


drop login DBLogin
drop user Mike


DECLARE @rolestmt NVARCHAR(200);
SET @rolestmt = 'ALTER ROLE db_datareader ADD ' + @name + ''
EXEC (@rolestmt);




 -- TESTS

create login stupidLogin with password = 'stupidPassword'
create user stupidUser for login stupidLogin
create database Stupidtest
grant all on [dbo].Stupidtest to stupidUser
use Stupidtest
grant execute on Stupidtest to stupidUser

use Stupidtest
go
exec sp_addrolemember 'db_owner', 'stupidUser'
go

use master
go
exec sp_addrolemember 'db_datareader', 'stupidUser'
go

alter role db_datareader add stupidLogin




 -- configure 'contained database' feature
EXEC sp_configure 'CONTAINED DATABASE AUTHENTICATION', 1
GO
RECONFIGURE
GO


 -- make Bookstore a contained (portable) database
ALTER DATABASE Bookstore SET CONTAINMENT = PARTIAL
GO

 -- create database user with password 
USE Bookstore
CREATE USER TestUser1 WITH PASSWORD = 'TestPassword1'

 -- grant/deny database level permissions
 -- 'ALL' is deprecated
USE Bookstore
GRANT ALL ON DATABASE::Bookstore TO TestUser1
ALTER ROLE db_owner ADD MEMBER TestUser1





-- -- procedure using contained db
CREATE PROCEDURE challenge2 @name NVARCHAR(30), @pass NVARCHAR(20)
AS
	-- -- lots of dynamic queries
	-- -- trying to avoid sql injection
	-- -- avoiding quotes problems

	-- -- create contained db
	DECLARE @dbName NVARCHAR(20)
	SET @dbName = 'TestDB'
	DECLARE @dbCreation NVARCHAR(30)
	SET @dbCreation  = N'CREATE DATABASE @dbNameparam'
	EXECUTE sp_executesql
		@dbCreation,
		N'@dbNameparam NVARCHAR(20)',
		@dbNameparam = @dbName
	DECLARE @dbAlter NVARCHAR(50)
	SET @dbAlter = N'ALTER DATABASE @dbNameAlter SET CONTAINMENT = PARTIAL'
	EXECUTE sp_executesql
		@dbAlter,
		N'@dbNameAlter NVARCHAR(20)',
		@dbNameAlter = @dbName

	-- -- use db
	DECLARE @usedb NVARCHAR(MAX) = N'USE @dbNameUse'
	EXECUTE sp_executesql
		@usedb,
		N'@dbNameUse NVARCHAR(20)',
		@dbNameUse = @dbName

	-- -- create user
	DECLARE @userstmt NVARCHAR(200)
	SET @userstmt = N'CREATE USER @username WITH PASSWORD = @userpass'
	EXECUTE sp_executesql 
		@userstmt,
		N'@username NVARCHAR(20), @userpass NVARCHAR(30)',
		@username = @name, @userpass = @pass

	-- -- give full access to user created in the new db
	DECLARE @roleparam2 NVARCHAR(20) = 'db_owner'
	DECLARE @ownerRole NVARCHAR(MAX)
	SET @ownerRole = N'ALTER ROLE @roleparam3 ADD MEMBER @namePar'
	EXECUTE sp_executesql
		@ownerRole,
		N'@roleparam3 NVARCHAR(20), @namePar NVARCHAR(30)',
		@roleparam3 = @roleparam2, @namePar = @name

	
	-- -- give read access to user created for rest of db
	--DECLARE @roleparam1 NVARCHAR(20) = 'db_datareader';
	--DECLARE @readRole NVARCHAR(MAX);
	--DECLARE @changedb NVARCHAR(MAX) = N'USE master';
	--EXEC sys.sp_executesql @stmt = @changedb;
	--SET @readRole = N'EXEC sp_addrolemember @roleparam1, @name';
	--EXEC sys.sp_executesql 
	--	@stmt = @readRole,
	--	@params = N'@roleparam1 NVARCHAR(20), @name NVARCHAR(30)',
	--	@roleparam1 = @roleparam1, @name = @name;
GO


EXEC challenge2 'Zoe', 'Password1'


-- -- less dynamic queries, more hard coded due to errors
-- -- still some syntax problems
CREATE PROCEDURE challenge3 @name NVARCHAR(30), @pass NVARCHAR(20)
AS
	-- -- create contained db
	CREATE DATABASE TestDB
	ALTER DATABASE TestDB SET CONTAINMENT = PARTIAL

	-- -- use db
	DECLARE @usedb NVARCHAR(MAX) = N'USE TestDB'
	EXECUTE sp_executesql @usedb;

	-- -- create user
	DECLARE @userstmt NVARCHAR(200)
	SET @userstmt = N'CREATE USER @username WITH PASSWORD = @userpass'
	DECLARE @paramList1 NVARCHAR(200)
	SET @paramList1 = N'@username NVARCHAR(20), @userpass NVARCHAR(30)'
	EXECUTE sp_executesql @userstmt, @paramList1,
		@username = @name, @userpass = @pass;

	-- -- give full access to user created in the new db
	DECLARE @roleparam2 NVARCHAR(20) = 'db_owner'
	DECLARE @ownerRole NVARCHAR(MAX)
	SET @ownerRole = N'ALTER ROLE @roleparam3 ADD MEMBER @namePar'
	DECLARE @paramList2 NVARCHAR(200)
	SET @paramList2 = N'@roleparam3 NVARCHAR(20), @namePar NVARCHAR(30)'
	EXECUTE sp_executesql @ownerRole, @paramList2,
		@roleparam3 = @roleparam2, @namePar = @name;
GO



EXEC challenge3 'Zoe', 'Password1'
