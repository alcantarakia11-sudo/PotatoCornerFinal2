-- QUICK FIX: Reset all passwords to plain text
-- Run this in SQL Server Management Studio

USE PotatoCorner_DB;
GO

PRINT '═══════════════════════════════════════════════════════════════';
PRINT 'RESETTING ALL PASSWORDS TO PLAIN TEXT';
PRINT '═══════════════════════════════════════════════════════════════';

-- Reset admin password
UPDATE USERS
SET [Password] = 'admin1290'
WHERE UserName = 'admin' OR MembershipLevel = 'Admin';

-- Reset kalyna password
UPDATE USERS
SET [Password] = 'password123'
WHERE UserName = 'kalyna';

-- Reset admin_flores password
UPDATE USERS
SET [Password] = 'password123'
WHERE UserName = 'admin_flores';

-- Reset kiahaha password (if exists)
UPDATE USERS
SET [Password] = 'password123'
WHERE UserName = 'kiahaha';

PRINT '';
PRINT 'Passwords reset successfully!';
PRINT '';
PRINT 'Login credentials:';
PRINT '  admin / admin1290';
PRINT '  kalyna / password123';
PRINT '  admin_flores / password123';
PRINT '  kiahaha / password123';
PRINT '';

-- Show all users
SELECT 
    CustomerID,
    UserName,
    Email,
    [Password],
    MembershipLevel,
    LEN([Password]) AS PasswordLength
FROM USERS
ORDER BY CustomerID;

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
GO
