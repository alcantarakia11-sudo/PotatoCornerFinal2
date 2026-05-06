-- Complete Stock Cleanup - Remove ALL duplicates
USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'CLEANING UP PRODUCTSIZESTOCK';
PRINT '========================================';

-- Backup ProductSizeStock quantities
SELECT ProductID, SizeID, MAX(StockQuantity) AS MaxStock
INTO #ProductSizeStockBackup
FROM ProductSizeStock
GROUP BY ProductID, SizeID;

-- Delete ALL ProductSizeStock entries
PRINT 'Removing all ProductSizeStock entries...';
DELETE FROM ProductSizeStock;

-- Re-insert only unique product-size combinations
PRINT 'Re-inserting unique ProductSizeStock entries...';
INSERT INTO ProductSizeStock (ProductID, SizeID, StockQuantity, LowStockThreshold, LastUpdated)
SELECT 
    ProductID, 
    SizeID,
    MaxStock, 
    10 AS LowStockThreshold, 
    GETDATE() AS LastUpdated
FROM #ProductSizeStockBackup;

DROP TABLE #ProductSizeStockBackup;

PRINT 'ProductSizeStock cleanup completed!';
SELECT COUNT(*) AS TotalProductSizes FROM ProductSizeStock;

PRINT '';
PRINT '========================================';
PRINT 'CLEANING UP FLAVORSTOCK';
PRINT '========================================';

-- Backup FlavorStock quantities
SELECT FlavorID, MAX(StockQuantity) AS MaxStock
INTO #FlavorStockBackup
FROM FlavorStock
GROUP BY FlavorID;

-- Delete ALL FlavorStock entries
PRINT 'Removing all FlavorStock entries...';
DELETE FROM FlavorStock;

-- Re-insert only unique flavors
PRINT 'Re-inserting unique FlavorStock entries...';
INSERT INTO FlavorStock (FlavorID, StockQuantity, LowStockThreshold, LastUpdated)
SELECT 
    FlavorID, 
    MaxStock, 
    5 AS LowStockThreshold, 
    GETDATE() AS LastUpdated
FROM #FlavorStockBackup;

DROP TABLE #FlavorStockBackup;

PRINT 'FlavorStock cleanup completed!';
SELECT COUNT(*) AS TotalFlavors FROM FlavorStock;

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION - FINAL RESULTS';
PRINT '========================================';

-- Show ProductSizeStock after cleanup
PRINT 'ProductSizeStock entries (should have no duplicates):';
SELECT 
    p.ProductName,
    ps.SizeName,
    COUNT(*) AS Count,
    MAX(pss.StockQuantity) AS Stock
FROM ProductSizeStock pss
INNER JOIN Products p ON pss.ProductID = p.ProductID
INNER JOIN ProductSizes ps ON pss.SizeID = ps.SizeID
GROUP BY p.ProductName, ps.SizeName
ORDER BY p.ProductName, ps.SizeName;

-- Show FlavorStock after cleanup
PRINT 'FlavorStock entries (should have no duplicates):';
SELECT 
    pf.FlavorName,
    COUNT(*) AS Count,
    fs.StockQuantity AS Stock
FROM FlavorStock fs
INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
GROUP BY pf.FlavorName, fs.StockQuantity
ORDER BY pf.FlavorName;

PRINT '';
PRINT 'Cleanup completed successfully!';
PRINT 'All duplicates have been removed.';
GO
