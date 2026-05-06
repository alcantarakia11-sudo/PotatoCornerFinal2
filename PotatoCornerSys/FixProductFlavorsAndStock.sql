-- Fix ProductFlavors table and clean up stock
USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'STEP 1: BACKUP AND IDENTIFY UNIQUE FLAVORS';
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
PRINT 'STEP 2: UPDATE FLAVORSTOCK TO USE UNIQUE FLAVORIDS';
PRINT '========================================';

-- For each duplicate FlavorID in FlavorStock, update to use the kept FlavorID
-- Then delete duplicates

-- Update FlavorStock to consolidate stock quantities
UPDATE fs
SET fs.FlavorID = fm.KeepFlavorID,
    fs.StockQuantity = (
        SELECT SUM(fs2.StockQuantity) 
        FROM FlavorStock fs2 
        INNER JOIN ProductFlavors pf2 ON fs2.FlavorID = pf2.FlavorID
        WHERE pf2.FlavorName = pf.FlavorName
    )
FROM FlavorStock fs
INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
INNER JOIN #FlavorMapping fm ON pf.FlavorName = fm.FlavorName
WHERE fs.FlavorID != fm.KeepFlavorID;

-- Delete duplicate FlavorStock entries (keep only the ones with KeepFlavorID)
DELETE fs
FROM FlavorStock fs
WHERE NOT EXISTS (
    SELECT 1 FROM #FlavorMapping fm WHERE fs.FlavorID = fm.KeepFlavorID
);

-- Ensure only one entry per flavor
DELETE FROM FlavorStock
WHERE StockID NOT IN (
    SELECT MIN(StockID)
    FROM FlavorStock
    GROUP BY FlavorID
);

PRINT 'FlavorStock updated and cleaned!';
SELECT COUNT(*) AS RemainingFlavorStockEntries FROM FlavorStock;

PRINT '';
PRINT '========================================';
PRINT 'STEP 3: DELETE DUPLICATE PRODUCTFLAVORS';
PRINT '========================================';

-- Delete duplicate ProductFlavors (keep only the ones with KeepFlavorID)
DELETE FROM ProductFlavors
WHERE FlavorID NOT IN (
    SELECT KeepFlavorID FROM #FlavorMapping
);

PRINT 'Duplicate ProductFlavors deleted!';
SELECT COUNT(*) AS RemainingProductFlavors FROM ProductFlavors;

PRINT '';
PRINT '========================================';
PRINT 'STEP 4: VERIFICATION';
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

-- Clean up temp table
DROP TABLE #FlavorMapping;

PRINT '';
PRINT 'Cleanup completed successfully!';
PRINT 'ProductFlavors and FlavorStock are now clean.';
GO
