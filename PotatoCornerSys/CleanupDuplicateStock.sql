-- Cleanup Duplicate Stock Entries
USE PotatoCorner_DB;
GO

-- First, let's see what duplicates exist
PRINT 'Checking for duplicate ProductSizeStock entries...';
SELECT ProductID, SizeID, COUNT(*) as DuplicateCount
FROM ProductSizeStock
GROUP BY ProductID, SizeID
HAVING COUNT(*) > 1;

PRINT 'Checking for duplicate FlavorStock entries...';
SELECT FlavorID, COUNT(*) as DuplicateCount
FROM FlavorStock
GROUP BY FlavorID
HAVING COUNT(*) > 1;

-- Remove duplicate ProductSizeStock entries (keep only the first one)
PRINT 'Removing duplicate ProductSizeStock entries...';
WITH CTE AS (
    SELECT StockID, 
           ROW_NUMBER() OVER (PARTITION BY ProductID, SizeID ORDER BY StockID) AS RowNum
    FROM ProductSizeStock
)
DELETE FROM CTE WHERE RowNum > 1;

-- Remove duplicate FlavorStock entries (keep only the first one)
PRINT 'Removing duplicate FlavorStock entries...';
WITH CTE AS (
    SELECT StockID, 
           ROW_NUMBER() OVER (PARTITION BY FlavorID ORDER BY StockID) AS RowNum
    FROM FlavorStock
)
DELETE FROM CTE WHERE RowNum > 1;

-- Verify cleanup
PRINT 'Verification after cleanup:';
SELECT 'ProductSizeStock' AS TableName, COUNT(*) AS TotalRecords FROM ProductSizeStock
UNION ALL
SELECT 'FlavorStock' AS TableName, COUNT(*) AS TotalRecords FROM FlavorStock;

PRINT 'Cleanup completed successfully!';
GO
