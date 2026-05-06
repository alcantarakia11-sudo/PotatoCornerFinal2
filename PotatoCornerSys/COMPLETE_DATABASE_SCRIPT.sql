-- ═══════════════════════════════════════════════════════════════
-- POTATO CORNER COMPLETE DATABASE CREATION SCRIPT
-- ═══════════════════════════════════════════════════════════════
-- This script creates the ENTIRE database from scratch
-- Database Name: PotatoCorner_DB
-- Run this script ONCE in SQL Server Management Studio
-- ═══════════════════════════════════════════════════════════════

USE master;
GO

-- Drop database if exists (CAUTION: Deletes all data!)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'PotatoCorner_DB')
BEGIN
    ALTER DATABASE PotatoCorner_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PotatoCorner_DB;
    PRINT 'Existing database dropped.';
END
GO

-- Create new database
CREATE DATABASE PotatoCorner_DB;
GO

PRINT '═══════════════════════════════════════════════════════════════';
PRINT 'Database PotatoCorner_DB created successfully!';
PRINT '═══════════════════════════════════════════════════════════════';
GO

USE PotatoCorner_DB;
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 1: USERS
-- ═══════════════════════════════════════════════════════════════
PRINT 'Creating USERS table...';
CREATE TABLE USERS (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(50) NOT NULL UNIQUE,
    Fullname NVARCHAR(100) NOT NULL,
    [Address] NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber NVARCHAR(11) NOT NULL UNIQUE,
    [Password] NVARCHAR(255) NOT NULL,
    Points INT DEFAULT 0,
    MembershipLevel NVARCHAR(20) DEFAULT 'Regular',
    DateCreated DATETIME DEFAULT GETDATE(),
    CONSTRAINT CHK_MembershipLevel CHECK (MembershipLevel IN ('Regular', 'Royalty', 'Admin'))
);
PRINT 'USERS table created!';
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 2: MEMBERSHIP
-- ═══════════════════════════════════════════════════════════════
PRINT 'Creating Membership table...';
CREATE TABLE Membership (
    MembershipID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    MembershipNumber NVARCHAR(50) UNIQUE,
    MembershipType NVARCHAR(20) DEFAULT 'Royalty',
    DateJoined DATETIME DEFAULT GETDATE(),
    ProfileImagePath NVARCHAR(500) NULL,
    FOREIGN KEY (CustomerID) REFERENCES USERS(CustomerID) ON DELETE CASCADE
);
PRINT 'Membership table created!';
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 3: CATEGORIES
-- ═══════════════════════════════════════════════════════════════
PRINT 'Creating Categories table...';
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL UNIQUE,
    [Description] NVARCHAR(255) NULL
);
PRINT 'Categories table created!';
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 4: PRODUCTS
-- ═══════════════════════════════════════════════════════════════
PRINT 'Creating Products table...';
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    CategoryID INT NOT NULL,
    [Description] NVARCHAR(255) NULL,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
PRINT 'Products table created!';
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 5: PRODUCTSIZES
-- ═══════════════════════════════════════════════════════════════
PRINT 'Creating ProductSizes table...';
CREATE TABLE ProductSizes (
    SizeID INT IDENTITY(1,1) PRIMARY KEY,
    SizeName NVARCHAR(50) NOT NULL UNIQUE,
    Price DECIMAL(10,2) NOT NULL
);
PRINT 'ProductSizes table created!';
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 6: PRODUCTFLAVORS
-- ═══════════════════════════════════════════════════════════════
PRINT 'Creating ProductFlavors table...';
CREATE TABLE ProductFlavors (
    FlavorID INT IDENTITY(1,1) PRIMARY KEY,
    FlavorName NVARCHAR(50) NOT NULL UNIQUE
);
PRINT 'ProductFlavors table created!';
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 7: PRODUCTSIZESTOCK
-- ═══════════════════════════════════════════════════════════════
PRINT 'Creating ProductSizeStock table...';
CREATE TABLE ProductSizeStock (
    StockID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    SizeID INT NOT NULL,
    StockQuantity INT DEFAULT 50,
    LowStockThreshold INT DEFAULT 10,
    LastUpdated DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (SizeID) REFERENCES ProductSizes(SizeID),
    CONSTRAINT CHK_StockQuantity CHECK (StockQuantity >= 0)
);
PRINT 'ProductSizeStock table created!';
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 8: FLAVORSTOCK
-- ═══════════════════════════════════════════════════════════════
PRINT 'Creating FlavorStock table...';
CREATE TABLE FlavorStock (
    FlavorStockID INT IDENTITY(1,1) PRIMARY KEY,
    FlavorID INT NOT NULL,
    StockQuantity INT DEFAULT 50,
    LowStockThreshold INT DEFAULT 5,
    LastUpdated DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (FlavorID) REFERENCES ProductFlavors(FlavorID),
    CONSTRAINT CHK_FlavorStock CHECK (StockQuantity >= 0)
);
PRINT 'FlavorStock table created!';
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 9: ORDERS
-- ═══════════════════════════════════════════════════════════════
PRINT 'Creating Orders table...';
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    CustomerName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(11) NOT NULL,
    [Address] NVARCHAR(255) NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    OrderStatus NVARCHAR(50) DEFAULT 'Pending',
    OrderType NVARCHAR(20) DEFAULT 'Delivery',
    PickupLocation NVARCHAR(100) NULL,
    ScheduledPickupTime DATETIME NULL,
    ActualPickupTime DATETIME NULL,
    FOREIGN KEY (CustomerID) REFERENCES USERS(CustomerID),
    CONSTRAINT CHK_OrderStatus CHECK (OrderStatus IN ('Pending', 'Confirmed', 'Out for Delivery', 'Delivered', 'Picked Up', 'No Show', 'Cancelled')),
    CONSTRAINT CHK_OrderType CHECK (OrderType IN ('Delivery', 'Walk-in'))
);
PRINT 'Orders table created!';
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 10: ORDERITEMS
-- ═══════════════════════════════════════════════════════════════
PRINT 'Creating OrderItems table...';
CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    SizeID INT NOT NULL,
    FlavorID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (SizeID) REFERENCES ProductSizes(SizeID),
    FOREIGN KEY (FlavorID) REFERENCES ProductFlavors(FlavorID),
    CONSTRAINT CHK_Quantity CHECK (Quantity > 0)
);
PRINT 'OrderItems table created!';
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT 'ALL TABLES CREATED SUCCESSFULLY!';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';

-- ═══════════════════════════════════════════════════════════════
-- INSERT DEFAULT DATA
-- ═══════════════════════════════════════════════════════════════

PRINT 'Inserting default data...';
PRINT '';

-- Insert Categories
PRINT 'Inserting Categories...';
INSERT INTO Categories (CategoryName, [Description])
VALUES ('French Fries', 'Flavored french fries in various sizes');
PRINT 'Categories inserted!';
GO

-- Insert Products
PRINT 'Inserting Products...';
INSERT INTO Products (ProductName, CategoryID, [Description])
VALUES ('French Fries', 1, 'Potato Corner signature flavored fries');
PRINT 'Products inserted!';
GO

-- Insert Product Sizes
PRINT 'Inserting Product Sizes...';
INSERT INTO ProductSizes (SizeName, Price)
VALUES 
('Regular', 89.00),
('Large', 129.00),
('Mega', 189.00),
('Giga', 249.00);
PRINT 'Product Sizes inserted!';
GO

-- Insert Product Flavors
PRINT 'Inserting Product Flavors...';
INSERT INTO ProductFlavors (FlavorName)
VALUES 
('BBQ'),
('Cheese'),
('Sour Cream'),
('Chili BBQ'),
('Salt'),
('Wasabi'),
('Cheddar'),
('Sweet Corn');
PRINT 'Product Flavors inserted!';
GO

-- Insert Stock for Product Sizes (50 units each)
PRINT 'Initializing Product Size Stock...';
INSERT INTO ProductSizeStock (ProductID, SizeID, StockQuantity, LowStockThreshold)
SELECT 
    p.ProductID,
    ps.SizeID,
    50 AS StockQuantity,
    10 AS LowStockThreshold
FROM Products p
CROSS JOIN ProductSizes ps;
PRINT 'Product Size Stock initialized!';
GO

-- Insert Stock for Flavors (50 units each)
PRINT 'Initializing Flavor Stock...';
INSERT INTO FlavorStock (FlavorID, StockQuantity, LowStockThreshold)
SELECT 
    FlavorID,
    50 AS StockQuantity,
    5 AS LowStockThreshold
FROM ProductFlavors;
PRINT 'Flavor Stock initialized!';
GO

-- Insert Admin User
PRINT 'Creating Admin account...';
INSERT INTO USERS (UserName, Fullname, [Address], Email, PhoneNumber, [Password], Points, MembershipLevel)
VALUES ('admin', 'Administrator', 'Potato Corner HQ', 'admin@potatocorner.com', '09123456789', 'admin1290', 0, 'Admin');
PRINT 'Admin account created!';
GO

-- Insert Sample Users
PRINT 'Creating sample users...';
INSERT INTO USERS (UserName, Fullname, [Address], Email, PhoneNumber, [Password], Points, MembershipLevel)
VALUES 
('kalyna', 'Kalyna', '123 Main St, Manila', 'meckiahaalcantara15@gmail.com', '09876543210', 'password123', 150, 'Regular'),
('admin_flores', 'Admin Flores', '456 Oak Ave, Quezon City', 'aeschenflores@gmail.com', '09111222333', 'password123', 250, 'Royalty');
PRINT 'Sample users created!';
GO

-- Insert Membership for Royalty Member
PRINT 'Creating Royalty Membership...';
INSERT INTO Membership (CustomerID, MembershipNumber, MembershipType)
VALUES (3, 'PC-ROY-2024-001', 'Royalty');
PRINT 'Royalty Membership created!';
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT 'DATABASE SETUP COMPLETE!';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
PRINT 'Database: PotatoCorner_DB';
PRINT 'Tables Created: 10';
PRINT '  1. USERS';
PRINT '  2. Membership';
PRINT '  3. Categories';
PRINT '  4. Products';
PRINT '  5. ProductSizes';
PRINT '  6. ProductFlavors';
PRINT '  7. ProductSizeStock';
PRINT '  8. FlavorStock';
PRINT '  9. Orders';
PRINT '  10. OrderItems';
PRINT '';
PRINT 'Default Data:';
PRINT '  - Admin: admin / admin1290';
PRINT '  - 2 Sample Users';
PRINT '  - 1 Category (French Fries)';
PRINT '  - 1 Product (French Fries)';
PRINT '  - 4 Sizes (50 stock each)';
PRINT '  - 8 Flavors (50 stock each)';
PRINT '';
PRINT 'You can now login and start using the system!';
PRINT '═══════════════════════════════════════════════════════════════';
GO
