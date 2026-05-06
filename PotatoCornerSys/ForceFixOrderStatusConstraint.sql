-- ========================================
-- FORCE FIX ORDER STATUS CONSTRAINT
-- ========================================
-- This script forcefully removes ALL constraints on OrderStatus and creates a new one
-- Run this script in SQL Server Management Studio
-- ========================================

USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'FORCE FIXING ORDER STATUS CONSTRAINT';
PRINT '========================================';
PRINT '';

-- Find and drop ALL constraints on the Orders table that involve OrderStatus
DECLARE @ConstraintName NVARCHAR(200)
DECLARE @SQL NVARCHAR(500)

PRINT 'Finding all constraints on Orders table...';

DECLARE constraint_cursor CURSOR FOR
SELECT name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('Orders')

OPEN constraint_cursor
FETCH NEXT FROM constraint_cursor INTO @ConstraintName

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Dropping constraint: ' + @ConstraintName;
    SET @SQL = 'ALTER TABLE Orders DROP CONSTRAINT [' + @ConstraintName + ']';
    EXEC sp_executesql @SQL;
    PRINT 'Dropped: ' + @ConstraintName;
    FETCH NEXT FROM constraint_cursor INTO @ConstraintName
END

CLOSE constraint_cursor
DEALLOCATE constraint_cursor

PRINT '';
PRINT 'All old constraints removed!';
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
    name AS ConstraintName,
    definition AS CheckClause
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('Orders');

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
