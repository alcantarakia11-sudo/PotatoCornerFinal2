-- Manual script to fix existing order statuses
-- Run this in your database to update the ConfirmedAt and DeliveredAt fields

USE PotatoCorner_DB;
GO

-- Update orders that should be delivered (15+ minutes old)
UPDATE Orders 
SET OrderStatus = 'Delivered', 
    DeliveredAt = DATEADD(MINUTE, 15, OrderDate),
    ConfirmedAt = CASE 
        WHEN ConfirmedAt IS NULL THEN DATEADD(MINUTE, 5, OrderDate)
        ELSE ConfirmedAt 
    END
WHERE OrderStatus = 'Pending' 
AND DATEDIFF(MINUTE, OrderDate, GETDATE()) >= 15;

-- Update orders that should be confirmed (5-14 minutes old)
UPDATE Orders 
SET OrderStatus = 'Confirmed', 
    ConfirmedAt = DATEADD(MINUTE, 5, OrderDate)
WHERE OrderStatus = 'Pending' 
AND DATEDIFF(MINUTE, OrderDate, GETDATE()) >= 5
AND DATEDIFF(MINUTE, OrderDate, GETDATE()) < 15;

-- Show the results
SELECT 
    OrderID,
    OrderDate,
    OrderStatus,
    ConfirmedAt,
    DeliveredAt,
    DATEDIFF(MINUTE, OrderDate, GETDATE()) as MinutesOld
FROM Orders 
ORDER BY OrderDate DESC;

PRINT 'Order status update completed!';