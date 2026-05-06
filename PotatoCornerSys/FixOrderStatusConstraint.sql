-- ========================================
-- FIX ORDER STATUS CONSTRAINT
-- ========================================
-- This script fixes the OrderStatus CHECK constraint to allow "No Show" status
-- Run this script in SQL Server Management Studio
-- ========================================

USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'FIXING ORDER STATUS CONSTRAINT';
PRINT '========================================';
PRINT '';

-- First, let's see what constraints exist on the Orders table
PRINT 'Current constraints on Orders table:';
SELECT 
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    CHECK_CLAUSE
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
WHERE TABLE_NAME = 'Orders';

PRINT '';

-- Drop the existing CHECK constraint if it exists
DECLARE @ConstraintName NVARCHAR(200)
SELECT @ConstraintName = CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
WHERE TABLE_NAME = 'Orders' AND COLUMN_NAME = 'OrderStatus'

IF @ConstraintName IS NOT NULL
BEGIN
    PRINT 'Dropping existing OrderStatus constraint: ' + @ConstraintName;
    DECLARE @SQL NVARCHAR(500) = 'ALTER TABLE Orders DROP CONSTRAINT ' + @ConstraintName;
    EXEC sp_executesql @SQL;
    PRINT 'Constraint dropped successfully!';
END
ELSE
BEGIN
    PRINT 'No existing OrderStatus constraint found.';
END

PRINT '';

-- Add new CHECK constraint that includes all valid statuses including "No Show"
PRINT 'Adding new OrderStatus constraint with all valid statuses...';
ALTER TABLE Orders
ADD CONSTRAINT CK_Orders_OrderStatus 
CHECK (OrderStatus IN (
    'Pending',
    'Confirmed', 
    'Out for Delivery',
    'Delivered',
    'Picked Up',
    'No Show',
    'Cancelled'
));

PRINT 'New OrderStatus constraint added successfully!';
PRINT '';

-- Verify the new constraint
PRINT 'Verifying new constraint:';
SELECT 
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    CHECK_CLAUSE
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
WHERE TABLE_NAME = 'Orders';

PRINT '';
PRINT '========================================';
PRINT 'CONSTRAINT FIX COMPLETE!';
PRINT '========================================';
PRINT 'OrderStatus now accepts these values:';
PRINT '- Pending';
PRINT '- Confirmed';
PRINT '- Out for Delivery';
PRINT '- Delivered';
PRINT '- Picked Up';
PRINT '- No Show';
PRINT '- Cancelled';
PRINT '========================================';
GO