-- FINAL STOCK FIX - Clean everything and start fresh
USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'CLEANING UP ALL STOCK TABLES';
PRINT '========================================';

-- Step 1: Clear all stock tables
DELETE FROM ProductSizeStock;
DELETE FROM FlavorStock;

PRINT 'All stock tables cleared!';
PRINT '';

-- Step 2: Fix ProductSizes duplicates if they exist
PRINT 'Fixing ProductSizes duplicates...';

-- Keep only one SizeID per ProductID+SizeName combination
WITH SizeToKeep AS (
    SELECT 
        ProductID,
        SizeName,
        MIN(SizeID) AS KeepSizeID
    FROM ProductSizes
    GROUP BY ProductID, SizeName
)
-- Update OrderItems to use the kept SizeID
UPDATE oi
SET oi.SizeID = stk.KeepSizeID
FROM OrderItems oi
INNER JOIN ProductSizes ps ON oi.SizeID = ps.SizeID
INNER JOIN SizeToKeep stk ON ps.ProductID = stk.ProductID AND ps.SizeName = stk.SizeName
WHERE oi.SizeID != stk.KeepSizeID;

-- Delete duplicate ProductSizes
WITH SizeToKeep AS (
    SELECT 
        ProductID,
        SizeName,
        MIN(SizeID) AS KeepSizeID
    FROM ProductSizes
    GROUP BY ProductID, SizeName
)
DELETE FROM ProductSizes
WHERE SizeID NOT IN (SELECT KeepSizeID FROM SizeToKeep);

PRINT 'ProductSizes cleaned!';
PRINT '';

-- Step 3: Fix ProductFlavors duplicates if they exist
PRINT 'Fixing ProductFlavors duplicates...';

-- Keep only one FlavorID per FlavorName
WITH FlavorToKeep AS (
    SELECT 
        FlavorName,
        MIN(FlavorID) AS KeepFlavorID
    FROM ProductFlavors
    GROUP BY FlavorName
)
-- Update OrderItems to use the kept FlavorID
UPDATE oi
SET oi.FlavorID = ftk.KeepFlavorID
FROM OrderItems oi
INNER JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
INNER JOIN FlavorToKeep ftk ON pf.FlavorName = ftk.FlavorName
WHERE oi.FlavorID != ftk.KeepFlavorID;

-- Delete duplicate ProductFlavors
WITH FlavorToKeep AS (
    SELECT 
        FlavorName,
        MIN(FlavorID) AS KeepFlavorID
    FROM ProductFlavors
    GROUP BY FlavorName
)
DELETE FROM ProductFlavors
WHERE FlavorID NOT IN (SELECT KeepFlavorID FROM FlavorToKeep);

PRINT 'ProductFlavors cleaned!';
PRINT '';

-- Step 4: Re-create ProductSizeStock with normal quantities (50 units)
PRINT 'Creating fresh ProductSizeStock...';

INSERT INTO ProductSizeStock (ProductID, SizeID, StockQuantity, LowStockThreshold, LastUpdated)
SELECT 
    ps.ProductID,
    ps.SizeID,
    50 AS StockQuantity,
    10 AS LowStockThreshold,
    GETDATE() AS LastUpdated
FROM ProductSizes ps;

PRINT 'ProductSizeStock created with 50 units each!';
PRINT '';

-- Step 5: Re-create FlavorStock with normal quantities (50 units)
PRINT 'Creating fresh FlavorStock...';

INSERT INTO FlavorStock (FlavorID, StockQuantity, LowStockThreshold, LastUpdated)
SELECT 
    FlavorID,
    50 AS StockQuantity,
    5 AS LowStockThreshold,
    GETDATE() AS LastUpdated
FROM ProductFlavors;

PRINT 'FlavorStock created with 50 units each!';
PRINT '';

-- Step 6: Verification
PRINT '========================================';
PRINT 'VERIFICATION - FINAL COUNTS';
PRINT '========================================';

SELECT 'ProductFlavors' AS TableName, COUNT(*) AS TotalRecords FROM ProductFlavors
UNION ALL
SELECT 'FlavorStock' AS TableName, COUNT(*) AS TotalRecords FROM FlavorStock
UNION ALL
SELECT 'ProductSizes' AS TableName, COUNT(*) AS TotalRecords FROM ProductSizes
UNION ALL
SELECT 'ProductSizeStock' AS TableName, COUNT(*) AS TotalRecords FROM ProductSizeStock;

PRINT '';
PRINT 'Expected counts:';
PRINT '- ProductFlavors: 4 (Cheese, BBQ, Chili BBQ, Bacon & Cheese)';
PRINT '- FlavorStock: 4';
PRINT '- ProductSizes: 6 (2 products x 3 sizes each)';
PRINT '- ProductSizeStock: 6';
PRINT '';

-- Show what will appear in Update.aspx
PRINT '========================================';
PRINT 'PREVIEW OF UPDATE.ASPX';
PRINT '========================================';

SELECT 
    p.ProductName + ' - ' + ps.SizeName AS ProductName,
    'Size' AS Category,
    pss.StockQuantity AS CurrentStock
FROM ProductSizeStock pss
INNER JOIN Products p ON pss.ProductID = p.ProductID
INNER JOIN ProductSizes ps ON pss.SizeID = ps.SizeID
UNION ALL
SELECT 
    pf.FlavorName AS ProductName,
    'Flavor' AS Category,
    fs.StockQuantity AS CurrentStock
FROM FlavorStock fs
INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
ORDER BY Category, ProductName;

PRINT '';
PRINT '========================================';
PRINT 'DONE! Stock is now clean with 50 units each.';
PRINT 'Refresh Update.aspx to see the results.';
PRINT '========================================';
GO
