-- Check what's actually in the stock tables
USE PotatoCorner_DB;
GO

-- Show all ProductSizeStock entries grouped
PRINT 'ProductSizeStock entries:';
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

-- Show all FlavorStock entries grouped
PRINT 'FlavorStock entries:';
SELECT 
    pf.FlavorName,
    COUNT(*) AS Count,
    MAX(fs.StockQuantity) AS Stock
FROM FlavorStock fs
INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
GROUP BY pf.FlavorName
ORDER BY pf.FlavorName;

-- Show actual duplicates in FlavorStock
PRINT 'Duplicate FlavorStock entries (if any):';
SELECT 
    pf.FlavorName,
    fs.FlavorID,
    COUNT(*) AS DuplicateCount
FROM FlavorStock fs
INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
GROUP BY pf.FlavorName, fs.FlavorID
HAVING COUNT(*) > 1;
