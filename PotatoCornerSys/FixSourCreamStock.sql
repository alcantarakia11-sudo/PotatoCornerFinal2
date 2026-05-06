-- ========================================
-- FIX SOUR CREAM STOCK TO 50
-- ========================================
-- This script resets Sour Cream flavor stock to 50 units
-- Run this in SQL Server Management Studio
-- ========================================

USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'FIXING SOUR CREAM STOCK';
PRINT '========================================';
PRINT '';

-- Check current stock
PRINT 'Current Sour Cream stock:';
SELECT 
    FlavorID,
    FlavorName,
    StockQuantity
FROM FlavorStock
WHERE FlavorName = 'Sour Cream';

PRINT '';

-- Update Sour Cream stock to 50
PRINT 'Updating Sour Cream stock to 50...';
UPDATE FlavorStock
SET StockQuantity = 50
WHERE FlavorName = 'Sour Cream';

PRINT 'Sour Cream stock updated successfully!';
PRINT '';

-- Verify the update
PRINT 'Updated Sour Cream stock:';
SELECT 
    FlavorID,
    FlavorName,
    StockQuantity
FROM FlavorStock
WHERE FlavorName = 'Sour Cream';

PRINT '';
PRINT '========================================';
PRINT 'STOCK FIX COMPLETE!';
PRINT '========================================';
PRINT 'Sour Cream stock is now set to 50 units.';
PRINT '========================================';
GO
