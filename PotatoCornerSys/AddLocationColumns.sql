-- ========================================
-- ADD LOCATION COLUMNS TO ORDERS TABLE
-- ========================================
-- This script adds Barangay and Street columns to the Orders table
-- for the new location dropdown and address features
-- Run this script in SQL Server Management Studio
-- ========================================

USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'ADDING LOCATION COLUMNS TO ORDERS TABLE';
PRINT '========================================';
PRINT '';

-- Check if columns already exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'Barangay')
BEGIN
    PRINT 'Adding Barangay column...';
    ALTER TABLE Orders
    ADD Barangay NVARCHAR(100) NULL;
    PRINT 'Barangay column added successfully!';
END
ELSE
BEGIN
    PRINT 'Barangay column already exists. Skipping...';
END

PRINT '';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'Street')
BEGIN
    PRINT 'Adding Street column...';
    ALTER TABLE Orders
    ADD Street NVARCHAR(200) NULL;
    PRINT 'Street column added successfully!';
END
ELSE
BEGIN
    PRINT 'Street column already exists. Skipping...';
END

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION';
PRINT '========================================';
PRINT 'Checking Orders table structure...';
PRINT '';

-- Show the Orders table structure
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Orders'
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT '========================================';
PRINT 'UPDATE COMPLETE!';
PRINT '========================================';
PRINT 'The Orders table now includes:';
PRINT '- Barangay column (stores selected location)';
PRINT '- Street column (stores street address)';
PRINT '';
PRINT 'These columns support the new features:';
PRINT '1. Location dropdown with delivery/walk-in options';
PRINT '2. Street address textbox for delivery orders';
PRINT '';
PRINT 'Available Barangays:';
PRINT '  DELIVERY ONLY:';
PRINT '    - Balisong';
PRINT '    - Talo-ot';
PRINT '    - Tulic';
PRINT '    - Talaga';
PRINT '    - Bogo';
PRINT '    - Binlod';
PRINT '    - Bulasa';
PRINT '';
PRINT '  BOTH (Walk-in + Delivery):';
PRINT '    - Poblacion';
PRINT '    - Lamacan';
PRINT '    - Langtad';
PRINT '    - Canbanua';
PRINT '========================================';
GO
