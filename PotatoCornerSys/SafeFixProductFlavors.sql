-- Safely fix ProductFlavors by updating all references first
USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'STEP 1: IDENTIFY UNIQUE FLAVORS';
PRINT '========================================';

-- Create a mapping of old FlavorIDs to new FlavorIDs
SELECT 
    FlavorName,
    MIN(FlavorID) AS KeepFlavorID,
    STRING_AGG(CAST(FlavorID AS VARCHAR), ',') AS AllFlavorIDs
INTO #FlavorMapping
FROM ProductFlavors
GROUP BY FlavorName;

SELECT * FROM #FlavorMapping;

PRINT '';
PRINT '========================================';
PRINT 'STEP 2: UPDATE ORDERITEMS TO USE UNIQUE FLAVORIDS';
PRINT '========================================';

-- Update OrderItems to use the kept FlavorID
UPDATE oi
SET oi.FlavorID = fm.KeepFlavorID
FROM OrderItems oi
INNER JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
INNER JOIN #FlavorMapping fm ON pf.FlavorName = fm.FlavorName
WHERE oi.FlavorID != fm.KeepFlavorID;

PRINT 'OrderItems updated to use unique FlavorIDs!';

PRINT '';
PRINT '========================================';
PRINT 'STEP 3: UPDATE FLAVORSTOCK TO USE UNIQUE FLAVORIDS';
PRINT '========================================';

-- First, consolidate stock quantities for each flavor
SELECT 
    fm.KeepFlavorID,
    SUM(fs.StockQuantity) AS TotalStock
INTO #ConsolidatedStock
FROM FlavorStock fs
INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
INNER JOIN #FlavorMapping fm ON pf.FlavorName = fm.FlavorName
GROUP BY fm.KeepFlavorID;

-- Delete all FlavorStock entries
DELETE FROM FlavorStock;

-- Re-insert with consolidated stock
INSERT INTO FlavorStock (FlavorID, StockQuantity, LowStockThreshold, LastUpdated)
SELECT 
    KeepFlavorID,
    TotalStock,
    5 AS LowStockThreshold,
    GETDATE() AS LastUpdated
FROM #ConsolidatedStock;

PRINT 'FlavorStock consolidated and cleaned!';

DROP TABLE #ConsolidatedStock;

PRINT '';
PRINT '========================================';
PRINT 'STEP 4: DELETE DUPLICATE PRODUCTFLAVORS';
PRINT '========================================';

-- Now safe to delete duplicate ProductFlavors
DELETE FROM ProductFlavors
WHERE FlavorID NOT IN (
    SELECT KeepFlavorID FROM #FlavorMapping
);

PRINT 'Duplicate ProductFlavors deleted!';

PRINT '';
PRINT '========================================';
PRINT 'STEP 5: VERIFICATION';
PRINT '========================================';

-- Verify ProductFlavors
PRINT 'ProductFlavors (should have 4 unique flavors):';
SELECT FlavorID, FlavorName FROM ProductFlavors ORDER BY FlavorName;

-- Verify FlavorStock
PRINT 'FlavorStock (should have 4 entries):';
SELECT 
    fs.StockID,
    pf.FlavorName,
    fs.StockQuantity
FROM FlavorStock fs
INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
ORDER BY pf.FlavorName;

-- Verify OrderItems are using correct FlavorIDs
PRINT 'OrderItems FlavorID distribution:';
SELECT 
    pf.FlavorName,
    COUNT(*) AS OrderCount
FROM OrderItems oi
INNER JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
GROUP BY pf.FlavorName
ORDER BY pf.FlavorName;

-- Clean up temp table
DROP TABLE #FlavorMapping;

PRINT '';
PRINT 'Cleanup completed successfully!';
PRINT 'All tables are now using unique FlavorIDs.';
GO
