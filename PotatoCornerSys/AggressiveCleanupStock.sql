-- Aggressive Cleanup - Remove ALL duplicates and keep only unique flavors
USE PotatoCorner_DB;
GO

-- First, backup the current stock quantities
PRINT 'Creating backup of stock quantities...';
SELECT FlavorID, MAX(StockQuantity) AS MaxStock
INTO #FlavorStockBackup
FROM FlavorStock
GROUP BY FlavorID;

-- Delete ALL FlavorStock entries
PRINT 'Removing all FlavorStock entries...';
DELETE FROM FlavorStock;

-- Re-insert only unique flavors with their max stock quantity
PRINT 'Re-inserting unique FlavorStock entries...';
INSERT INTO FlavorStock (FlavorID, StockQuantity, LowStockThreshold, LastUpdated)
SELECT 
    FlavorID, 
    MaxStock, 
    5 AS LowStockThreshold, 
    GETDATE() AS LastUpdated
FROM #FlavorStockBackup;

-- Clean up temp table
DROP TABLE #FlavorStockBackup;

-- Verify the cleanup
PRINT 'Verification:';
SELECT 
    pf.FlavorName,
    fs.StockQuantity,
    fs.LowStockThreshold
FROM FlavorStock fs
INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
ORDER BY pf.FlavorName;

PRINT 'Total FlavorStock entries: ';
SELECT COUNT(*) AS TotalFlavors FROM FlavorStock;

PRINT 'Cleanup completed!';
GO
