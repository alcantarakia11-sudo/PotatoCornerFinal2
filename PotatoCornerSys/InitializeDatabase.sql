-- Database Initialization Script for Potato Corner System
-- Run this script to ensure all required tables exist

USE PotatoCorner_DB;
GO

-- Create Membership table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Membership' AND xtype='U')
BEGIN
    CREATE TABLE Membership (
        MembershipID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT NOT NULL,
        MembershipType NVARCHAR(50) NOT NULL DEFAULT 'Royalty',
        RegistrationDate DATETIME NOT NULL DEFAULT GETDATE(),
        RegistrationFee DECIMAL(10,2) NOT NULL DEFAULT 100.00,
        PaymentMethod NVARCHAR(50) NOT NULL,
        RoyaltyNumber NVARCHAR(10) NOT NULL UNIQUE,
        ProfilePicture NVARCHAR(255) NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
    );
    
    -- Create indexes for better performance
    CREATE INDEX IX_Membership_CustomerID ON Membership(CustomerID);
    CREATE INDEX IX_Membership_RoyaltyNumber ON Membership(RoyaltyNumber);
    
    PRINT 'Membership table created successfully.';
END
ELSE
BEGIN
    PRINT 'Membership table already exists.';
END

-- Verify USERS table has required columns
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'USERS' AND COLUMN_NAME = 'MembershipLevel')
BEGIN
    ALTER TABLE USERS ADD MembershipLevel NVARCHAR(50) DEFAULT 'Guest';
    PRINT 'Added MembershipLevel column to USERS table.';
END

-- Verify Orders table exists (should already exist from previous work)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Orders' AND xtype='U')
BEGIN
    PRINT 'WARNING: Orders table does not exist. Please create it first.';
END

-- Show table status
SELECT 
    'USERS' as TableName, 
    COUNT(*) as RecordCount 
FROM USERS
UNION ALL
SELECT 
    'Membership' as TableName, 
    COUNT(*) as RecordCount 
FROM Membership
UNION ALL
SELECT 
    'Orders' as TableName, 
    COUNT(*) as RecordCount 
FROM Orders;

PRINT 'Database initialization completed.';