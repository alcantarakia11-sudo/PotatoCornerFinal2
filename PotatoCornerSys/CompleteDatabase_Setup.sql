-- ═══════════════════════════════════════════════════════════════
-- POTATO CORNER COMPLETE DATABASE SETUP SCRIPT
-- ═══════════════════════════════════════════════════════════════
-- This script creates the entire database from scratch
-- Run this script ONCE to set up everything

USE master;
GO

-- Drop database if exists (CAUTION: This deletes all data!)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'PotatoCornerDB')
BEGIN
    ALTER DATABASE PotatoCornerDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PotatoCornerDB;
END
GO

-- Create database
CREATE DATABASE PotatoCornerDB;
GO

USE PotatoCornerDB;
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 1: USERS
-- ═══════════════════════════════════════════════════════════════
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
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 2: MEMBERSHIP
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE Membership (
    MembershipID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    MembershipNumber NVARCHAR(50) UNIQUE,
    MembershipType NVARCHAR(20) DEFAULT 'Royalty',
    DateJoined DATETIME DEFAULT GETDATE(),
    ProfileImagePath NVARCHAR(500) NULL,
    FOREIGN KEY (CustomerID) REFERENCES USERS(CustomerID) ON DELETE CASCADE
);
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 3: PRODUCTS (Sizes)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(50) NOT NULL UNIQUE,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT DEFAULT 50,
    Category NVARCHAR(20) DEFAULT 'Size',
    CONSTRAINT CHK_StockQuantity CHECK (StockQuantity >= 0)
);
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 4: PRODUCTFLAVORS (Flavors)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE ProductFlavors (
    FlavorID INT IDENTITY(1,1) PRIMARY KEY,
    FlavorName NVARCHAR(50) NOT NULL UNIQUE,
    StockQuantity INT DEFAULT 50,
    CONSTRAINT CHK_FlavorStock CHECK (StockQuantity >= 0)
);
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 5: ORDERS
-- ═══════════════════════════════════════════════════════════════
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
GO

-- ═══════════════════════════════════════════════════════════════
-- TABLE 6: ORDERITEMS
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    FlavorID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (FlavorID) REFERENCES ProductFlavors(FlavorID),
    CONSTRAINT CHK_Quantity CHECK (Quantity > 0)
);
GO

-- ═══════════════════════════════════════════════════════════════
-- INSERT DEFAULT DATA
-- ═══════════════════════════════════════════════════════════════

-- Insert Admin User (password: admin1290)
INSERT INTO USERS (UserName, Fullname, [Address], Email, PhoneNumber, [Password], Points, MembershipLevel)
VALUES ('admin', 'Administrator', 'Potato Corner HQ', 'admin@potatocorner.com', '09123456789', 'admin1290', 0, 'Admin');
GO

-- Insert Sample Regular Users
INSERT INTO USERS (UserName, Fullname, [Address], Email, PhoneNumber, [Password], Points, MembershipLevel)
VALUES 
('kalyna', 'Kalyna', '123 Main St, Manila', 'meckiahaalcantara15@gmail.com', '09876543210', 'password123', 150, 'Regular'),
('admin_flores', 'Admin Flores', '456 Oak Ave, Quezon City', 'aeschenflores@gmail.com', '09111222333', 'password123', 250, 'Royalty');
GO

-- Insert Membership for Royalty Member
INSERT INTO Membership (CustomerID, MembershipNumber, MembershipType)
VALUES (3, 'PC-ROY-2024-001', 'Royalty');
GO

-- Insert Products (Sizes) with Stock
INSERT INTO Products (ProductName, Price, StockQuantity, Category)
VALUES 
('Regular', 89.00, 50, 'Size'),
('Large', 129.00, 50, 'Size'),
('Mega', 189.00, 50, 'Size'),
('Giga', 249.00, 50, 'Size');
GO

-- Insert Product Flavors with Stock
INSERT INTO ProductFlavors (FlavorName, StockQuantity)
VALUES 
('BBQ', 50),
('Cheese', 50),
('Sour Cream', 50),
('Chili BBQ', 50),
('Salt', 50),
('Wasabi', 50),
('Cheddar', 50),
('Sweet Corn', 50);
GO

PRINT '═══════════════════════════════════════════════════════════════';
PRINT 'DATABASE SETUP COMPLETE!';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT 'Database: PotatoCornerDB';
PRINT 'Tables Created: 6 (USERS, Membership, Products, ProductFlavors, Orders, OrderItems)';
PRINT 'Admin Account: admin / admin1290';
PRINT 'Sample Users: 2 regular users added';
PRINT 'Products: 4 sizes with 50 stock each';
PRINT 'Flavors: 8 flavors with 50 stock each';
PRINT '═══════════════════════════════════════════════════════════════';
GO
