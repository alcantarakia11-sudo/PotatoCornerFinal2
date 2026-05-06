-- Reset stock quantities to normal levels and fix ProductSizes
USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'STEP 1: RESET FLAVOR STOCK TO NORMAL LEVELS';
PRINT '========================================';

-- Reset FlavorStock to reasonable quantities (50 units each)
UPDATE FlavorStock
SET StockQuantity = 50,
    LowStockThreshold = 5,
    LastUpdated = GETDATE();

PRINT 'FlavorStock reset to 50 units each!';
SELECT 
    pf.FlavorName,
    fs.StockQuantity
FROM FlavorStock fs
INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
ORDER BY pf.FlavorName;

PRINT '';
PRINT '========================================';
PRINT 'STEP 2: FIX PRODUCTSIZES DUPLICATES';
PRINT '========================================';

-- Check for ProductSizes duplicates
SELECT 
    p.ProductName,
    ps.SizeName,
    COUNT(*) AS DuplicateCount,
    STRING_AGG(CAST(ps.SizeID AS VARCHAR), ',') AS SizeIDs
INTO #SizeMapping
FROM ProductSizes ps
INNER JOIN Products p ON ps.ProductID = p.ProductID
GROUP BY p.ProductName, ps.SizeName, ps.ProductID
HAVING COUNT(*) > 1;

-- If there are duplicates, show them
IF EXISTS (SELECT 1 FROM #SizeMapping)
BEGIN
    PRINT 'Found ProductSizes duplicates:';
    SELECT * FROM #SizeMapping;
    
    -- Create mapping to keep only the first SizeID
    SELECT 
        p.ProductName,
        ps.SizeName,
        ps.ProductID,
        MIN(ps.SizeID) AS KeepSizeID
    INTO #SizeKeepMapping
    FROM ProductSizes ps
    INNER JOIN Products p ON ps.ProductID = p.ProductID
    GROUP BY p.ProductName, ps.SizeName, ps.ProductID;
    
    -- Update OrderItems to use kept SizeIDs
    UPDATE oi
    SET oi.SizeID = skm.KeepSizeID
    FROM OrderItems oi
    INNER JOIN ProductSizes ps ON oi.SizeID = ps.SizeID
    INNER JOIN #SizeKeepMapping skm ON ps.ProductID = skm.ProductID AND ps.SizeName = skm.SizeName
    WHERE oi.SizeID != skm.KeepSizeID;
    
    -- Consolidate ProductSizeStock
    SELECT 
        skm.ProductID,
        skm.KeepSizeID,
        SUM(pss.StockQuantity) AS TotalStock
    INTO #ConsolidatedSizeStock
    FROM ProductSizeStock pss
    INNER JOIN ProductSizes ps ON pss.SizeID = ps.SizeID
    INNER JOIN #SizeKeepMapping skm ON ps.ProductID = skm.ProductID AND ps.SizeName = skm.SizeName
    GROUP BY skm.ProductID, skm.KeepSizeID;
    
    -- Delete all ProductSizeStock
    DELETE FROM ProductSizeStock;
    
    -- Re-insert with consolidated stock
    INSERT INTO ProductSizeStock (ProductID, SizeID, StockQuantity, LowStockThreshold, LastUpdated)
    SELECT 
        ProductID,
        KeepSizeID,
        TotalStock,
        10 AS LowStockThreshold,
        GETDATE() AS LastUpdated
    FROM #ConsolidatedSizeStock;
    
    -- Delete duplicate ProductSizes
    DELETE FROM ProductSizes
    WHERE SizeID NOT IN (
        SELECT KeepSizeID FROM #SizeKeepMapping
    );
    
    DROP TABLE #ConsolidatedSizeStock;
    DROP TABLE #SizeKeepMapping;
    
    PRINT 'ProductSizes duplicates fixed!';
END
ELSE
BEGIN
    PRINT 'No ProductSizes duplicates found.';
END

DROP TABLE #SizeMapping;

PRINT '';
PRINT '========================================';
PRINT 'STEP 3: RESET PRODUCTSIZESTOCK TO NORMAL LEVELS';
PRINT '========================================';

-- Reset ProductSizeStock to reasonable quantities (50 units each)
UPDATE ProductSizeStock
SET StockQuantity = 50,
    LowStockThreshold = 10,
    LastUpdated = GETDATE();

PRINT 'ProductSizeStock reset to 50 units each!';

PRINT '';
PRINT '========================================';
PRINT 'FINAL VERIFICATION';
PRINT '========================================';

-- Show final counts
SELECT 'ProductFlavors' AS TableName, COUNT(*) AS TotalRecords FROM ProductFlavors
UNION ALL
SELECT 'FlavorStock' AS TableName, COUNT(*) AS TotalRecords FROM FlavorStock
UNION ALL
SELECT 'ProductSizes' AS TableName, COUNT(*) AS TotalRecords FROM ProductSizes
UNION ALL
SELECT 'ProductSizeStock' AS TableName, COUNT(*) AS TotalRecords FROM ProductSizeStock;

-- Show sample of what's in Update page
PRINT 'Sample of what will appear in Update.aspx:';
SELECT TOP 10
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
PRINT 'All stock has been reset to normal levels (50 units)!';
PRINT 'Refresh Update.aspx to see the clean results.';
GO
