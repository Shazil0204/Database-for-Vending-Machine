-- Create the AdminLoginDB database
CREATE DATABASE IF NOT EXISTS AdminLoginDB;

USE AdminLoginDB;

-- Create the Positions table
CREATE TABLE IF NOT EXISTS Positions (
    PositionID INT AUTO_INCREMENT PRIMARY KEY,
    Position VARCHAR(50) NOT NULL
);

-- Create the Employees table
CREATE TABLE IF NOT EXISTS Employees (
    EmployeID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeNumber INT NOT NULL,
    FirstName VARCHAR(15) NOT NULL,
    LastName VARCHAR(15) NOT NULL,
    Age INT NOT NULL,
    PositionID INT NOT NULL,
    FOREIGN KEY (PositionID) REFERENCES Positions(PositionID)
);

-- Create the AllVendingMachinesDB database
CREATE DATABASE IF NOT EXISTS AllVendingMachinesDB;

USE AllVendingMachinesDB;

-- Create the Cities table
CREATE TABLE IF NOT EXISTS Cities (
    CityID INT AUTO_INCREMENT PRIMARY KEY,
    City VARCHAR(50) NOT NULL
);

-- Create the DBRecords table
CREATE TABLE IF NOT EXISTS DBRecords (
    DBID INT AUTO_INCREMENT PRIMARY KEY,
    DBName VARCHAR(50)
);

-- Stored Procedure: CREATING_VM
DELIMITER //
CREATE PROCEDURE CREATING_VM(IN CITY VARCHAR(100), OUT RESULT INT)
BEGIN
    DECLARE SQL_STMT TEXT;

    -- Initialize RESULT to a default value
    SET RESULT = -3;

    -- Check if the table already exists in MainDB
    IF EXISTS (
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = CITY AND table_name = 'Products'
    ) THEN
        SET RESULT = -2;
        SELECT 'THIS VENDING MACHINE ALREADY EXISTS';
        LEAVE;
    END IF;

    -- Check if the city name you have typed exists
    IF EXISTS (SELECT * FROM Cities WHERE City = CITY) THEN
        -- INSERT THIS DATABASE NAME INSIDE THE TABLE TO SHOW WHICH CITY HAS A VENDING MACHINE
        SET SQL_STMT = CONCAT('INSERT INTO DBRecords(DBName) VALUES (\'', CITY, '_VM\')');
        PREPARE stmt FROM SQL_STMT;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Create the new database
        SET SQL_STMT = CONCAT('CREATE DATABASE `', CITY, '_VM`');
        PREPARE stmt FROM SQL_STMT;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Create tables in the new database and insert data
        SET SQL_STMT = CONCAT('
            USE `', CITY, '_VM`;
            
            CREATE TABLE Brands (
                BrandID INT AUTO_INCREMENT PRIMARY KEY,
                ProductBrand VARCHAR(30) NOT NULL
            );
            
            CREATE TABLE Types (
                TypeID INT AUTO_INCREMENT PRIMARY KEY,
                ProductType VARCHAR(30)
            );
            
            CREATE TABLE Products (
                ProductID INT AUTO_INCREMENT PRIMARY KEY,
                ProductName VARCHAR(30),
                ProductURL NVARCHAR(1000),
                Stock INT,
                Price INT NOT NULL,
                BrandID INT NOT NULL,
                TypeID INT NOT NULL,
                FOREIGN KEY (BrandID) REFERENCES Brands (BrandID),
                FOREIGN KEY (TypeID) REFERENCES Types (TypeID)
            );
            
            CREATE TABLE Transactions (
                TransactionID INT AUTO_INCREMENT PRIMARY KEY,
                TotalPrice INT NOT NULL,
                Quantity INT NOT NULL,
                ProductID INT NOT NULL,
                FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
            );
            
            -- INSERT INTO BRANDS
            INSERT INTO Brands (ProductBrand) VALUES (''BrandA'');
            INSERT INTO Brands (ProductBrand) VALUES (''BrandB'');
            INSERT INTO Brands (ProductBrand) VALUES (''BrandC'');
            
            -- INSERT INTO TYPES
            INSERT INTO Types (ProductType) VALUES (''Type1'');
            INSERT INTO Types (ProductType) VALUES (''Type2'');
            INSERT INTO Types (ProductType) VALUES (''Type3'');
            
            -- INSERT INTO PRODUCTS
            INSERT INTO Products (ProductName, ProductURL, Stock, Price, BrandID, TypeID) VALUES (''ProductA1'', ''https://example.com/imageA1.jpg'', 100, 50, 1, 1);
            INSERT INTO Products (ProductName, ProductURL, Stock, Price, BrandID, TypeID) VALUES (''ProductA2'', ''https://example.com/imageA2.jpg'', 150, 60, 2, 2);
            INSERT INTO Products (ProductName, ProductURL, Stock, Price, BrandID, TypeID) VALUES (''ProductA3'', ''https://example.com/imageA3.jpg'', 200, 70, 3, 3);
            INSERT INTO Products (ProductName, ProductURL, Stock, Price, BrandID, TypeID) VALUES (''ProductB1'', ''https://example.com/imageB1.jpg'', 110, 55, 1, 2);
            INSERT INTO Products (ProductName, ProductURL, Stock, Price, BrandID, TypeID) VALUES (''ProductB2'', ''https://example.com/imageB2.jpg'', 155, 65, 2, 3);
            INSERT INTO Products (ProductName, ProductURL, Stock, Price, BrandID, TypeID) VALUES (''ProductB3'', ''https://example.com/imageB3.jpg'', 210, 75, 3, 1);
            INSERT INTO Products (ProductName, ProductURL, Stock, Price, BrandID, TypeID) VALUES (''ProductC1'', ''https://example.com/imageC1.jpg'', 120, 52, 1, 3);
            INSERT INTO Products (ProductName, ProductURL, Stock, Price, BrandID, TypeID) VALUES (''ProductC2'', ''https://example.com/imageC2.jpg'', 160, 62, 2, 1);
            INSERT INTO Products (ProductName, ProductURL, Stock, Price, BrandID, TypeID) VALUES (''ProductC3'', ''https://example.com/imageC3.jpg'', 220, 72, 3, 2);
        ');

        PREPARE stmt FROM SQL_STMT;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET RESULT = 0; -- Indicating success
        SELECT 'DONE SUCCESSFULLY';
    ELSE
        SET RESULT = -1; -- City name doesn't exist
        SELECT 'THIS CITY NAME DOES NOT EXIST IN OUR DATABASE';
    END IF;
END;
//
DELIMITER ;

-- Stored Procedure: READ_VM
DELIMITER //
CREATE PROCEDURE READ_VM(IN DBName VARCHAR(50), OUT RESULT INT)
BEGIN
    DECLARE SQL_STMT TEXT;

    IF EXISTS (
        SELECT schema_name
        FROM information_schema.schemata
        WHERE schema_name = DBName
    ) THEN
        SET SQL_STMT = CONCAT('USE `', DBName, '`');
        PREPARE stmt FROM SQL_STMT;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET SQL_STMT = '
            SELECT
                P.ProductName,
                P.ProductURL,
                P.Stock,
                P.Price,
                T.ProductType,
                B.ProductBrand
            FROM
                Products AS P
            INNER JOIN
                Brands AS B ON P.BrandID = B.BrandID
            INNER JOIN
                Types AS T ON P.TypeID = T.TypeID;
        ';

        PREPARE stmt FROM SQL_STMT;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET RESULT = 0;
        SELECT 'HERE YOU GO!';
    ELSE
        SET RESULT = -1;
        SELECT 'CAN''T FIND A DATABASE WITH THIS NAME';
    END IF;
END;
//
DELIMITER ;

-- Stored Procedure: UPDATE_VM
DELIMITER //
CREATE PROCEDURE UPDATE_VM(
    IN DBName VARCHAR(50),
    IN ProductID INT,
    IN ProductName VARCHAR(30),
    IN ProductURL NVARCHAR(1000),
    IN Stock INT,
    IN Price INT,
    IN BrandID INT,
    IN TypeID INT,
    OUT RESULT INT
)
BEGIN
    DECLARE SQL_STMT TEXT;

    IF EXISTS (
        SELECT schema_name
        FROM information_schema.schemata
        WHERE schema_name = DBName
    ) THEN
        -- Switch to the specified database
        SET SQL_STMT = CONCAT('USE `', DBName, '`');
        PREPARE stmt FROM SQL_STMT;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Update the product
        SET SQL_STMT = CONCAT('
            UPDATE Products 
            SET 
                ProductName = ?,
                ProductURL = ?,
                Stock = ?,
                Price = ?,
                BrandID = ?,
                TypeID = ?
            WHERE ProductID = ?
        ');

        PREPARE stmt FROM SQL_STMT;
        EXECUTE stmt USING ProductName, ProductURL, Stock, Price, BrandID, TypeID, ProductID;
        DEALLOCATE PREPARE stmt;

        SET RESULT = 0;
        SELECT CONCAT('SYSTEM HAVE UPDATED TABLE IN DATABASE `', DBName, '` SUCCESSFUL');
    ELSE
        SET RESULT = -1;
        SELECT 'SYSTEM CAN''T FIND A DATABASE WITH THIS NAME';
    END IF;
END;
//
DELIMITER ;

-- Stored Procedure: DELETING_VM
DELIMITER //
CREATE PROCEDURE DELETING_VM(IN CITY VARCHAR(100), OUT RESULT INT)
BEGIN
    DECLARE SQL_STMT TEXT;

    -- Check if the Database name you have typed exists
    IF EXISTS (SELECT * FROM DBRecords WHERE DBName = CITY) THEN
        SET SQL_STMT = CONCAT('DROP DATABASE `', CITY, '`');
        PREPARE stmt FROM SQL_STMT;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET SQL_STMT = CONCAT('DELETE FROM DBRecords WHERE DBName = ?');
        PREPARE stmt FROM SQL_STMT;
        EXECUTE stmt USING CITY;
        DEALLOCATE PREPARE stmt;

        SET RESULT = 0;
        SELECT 'DONE';
    ELSE 
        SET RESULT = -1;
        SELECT 'THERE IS NO DATABASE WITH THIS NAME. PLEASE CHECK YOUR INSERT TEXT AGAIN THANKS!';
    END IF;
END;
//
DELIMITER ;
