-- Diagnose the root cause of duplicates
USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'CHECKING PRODUCTFLAVORS TABLE';
PRINT '========================================';
-- Check if ProductFlavors has duplicate flavor names
SELECT 
    FlavorName,
    COUNT(*) AS HowManyTimesThisFlavorExists,
    STRING_AGG(CAST(FlavorID AS VARCHAR), ', ') AS FlavorIDs
FROM ProductFlavors
GROUP BY FlavorName
ORDER BY FlavorName;

PRINT '';
PRINT '========================================';
PRINT 'CHECKING FLAVORSTOCK TABLE';
PRINT '========================================';
-- Check FlavorStock entries
SELECT 
    fs.StockID,
    fs.FlavorID,
    pf.FlavorName,
    fs.StockQuantity
FROM FlavorStock fs
INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
ORDER BY pf.FlavorName, fs.StockID;

PRINT '';
PRINT '========================================';
PRINT 'CHECKING PRODUCTSIZES TABLE';
PRINT '========================================';
-- Check if ProductSizes has duplicates
SELECT 
    p.ProductName,
    ps.SizeName,
    COUNT(*) AS HowManyTimesThisSizeExists,
    STRING_AGG(CAST(ps.SizeID AS VARCHAR), ', ') AS SizeIDs
FROM ProductSizes ps
INNER JOIN Products p ON ps.ProductID = p.ProductID
GROUP BY p.ProductName, ps.SizeName
ORDER BY p.ProductName, ps.SizeName;

PRINT '';
PRINT '========================================';
PRINT 'CHECKING PRODUCTSIZESTOCK TABLE';
PRINT '========================================';
-- Check ProductSizeStock entries
SELECT TOP 20
    pss.StockID,
    p.ProductName,
    ps.SizeName,
    pss.StockQuantity
FROM ProductSizeStock pss
INNER JOIN Products p ON pss.ProductID = p.ProductID
INNER JOIN ProductSizes ps ON pss.SizeID = ps.SizeID
ORDER BY p.ProductName, ps.SizeName, pss.StockID;
