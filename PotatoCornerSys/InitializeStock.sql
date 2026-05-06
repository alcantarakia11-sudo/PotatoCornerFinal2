-- ========================================
-- POTATO CORNER STOCK INITIALIZATION SCRIPT
-- ========================================
-- This script sets up all stock tables with initial quantities
-- Run this script in SQL Server Management Studio
-- ========================================

USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'STEP 1: CLEAR EXISTING STOCK DATA';
PRINT '========================================';
PRINT 'Removing any existing stock entries...';
PRINT '';

-- Clear existing stock (if any)
DELETE FROM ProductSizeStock;
DELETE FROM FlavorStock;

PRINT 'Existing stock cleared!';
PRINT '';

PRINT '========================================';
PRINT 'STEP 2: INITIALIZE PRODUCT SIZE STOCK';
PRINT '========================================';
PRINT 'Setting up stock for all product sizes...';
PRINT '';

-- Insert stock for all product sizes (50 units each)
INSERT INTO ProductSizeStock (ProductID, SizeID, StockQuantity, LowStockThreshold, LastUpdated)
SELECT 
    ps.ProductID,
    ps.SizeID,
    50 AS StockQuantity,
    10 AS LowStockThreshold,
    GETDATE() AS LastUpdated
FROM ProductSizes ps;

PRINT 'Product size stock initialized!';
PRINT '';

-- Show what was created
SELECT 
    p.ProductName,
    ps.SizeName,
    pss.StockQuantity,
    pss.LowStockThreshold
FROM ProductSizeStock pss
INNER JOIN Products p ON pss.ProductID = p.ProductID
INNER JOIN ProductSizes ps ON pss.SizeID = ps.SizeID
ORDER BY p.ProductName, ps.SizeName;

PRINT '';
PRINT '========================================';
PRINT 'STEP 3: INITIALIZE FLAVOR STOCK';
PRINT '========================================';
PRINT 'Setting up stock for all flavors...';
PRINT '';

-- Insert stock for all flavors (50 units each)
INSERT INTO FlavorStock (FlavorID, StockQuantity, LowStockThreshold, LastUpdated)
SELECT 
    FlavorID,
    50 AS StockQuantity,
    5 AS LowStockThreshold,
    GETDATE() AS LastUpdated
FROM ProductFlavors;

PRINT 'Flavor stock initialized!';
PRINT '';

-- Show what was created
SELECT 
    pf.FlavorName,
    fs.StockQuantity,
    fs.LowStockThreshold
FROM FlavorStock fs
INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
ORDER BY pf.FlavorName;

PRINT '';
PRINT '========================================';
PRINT 'STEP 4: VERIFICATION';
PRINT '========================================';
PRINT 'Verifying all stock has been initialized...';
PRINT '';

-- Count total records
SELECT 
    'ProductSizeStock' AS TableName, 
    COUNT(*) AS TotalRecords,
    SUM(StockQuantity) AS TotalStock
FROM ProductSizeStock
UNION ALL
SELECT 
    'FlavorStock' AS TableName, 
    COUNT(*) AS TotalRecords,
    SUM(StockQuantity) AS TotalStock
FROM FlavorStock;

PRINT '';
PRINT '========================================';
PRINT 'INITIALIZATION COMPLETE!';
PRINT '========================================';
PRINT 'All stock has been set to 50 units each.';
PRINT 'Low stock threshold: 10 for sizes, 5 for flavors.';
PRINT '';
PRINT 'You can now:';
PRINT '1. Log in to the admin panel';
PRINT '2. Go to Update.aspx to manage stock';
PRINT '3. Add more stock as needed';
PRINT '========================================';
GO
