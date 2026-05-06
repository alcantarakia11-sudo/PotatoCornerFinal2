-- EMERGENCY: Reset passwords back to plain text
-- This will allow you to login again
-- Run this script, then you can login with original passwords

USE PotatoCornerDB;
GO

-- Reset admin password
UPDATE USERS
SET [Password] = 'admin1290'
WHERE UserName = 'admin' OR Email LIKE '%admin%' OR MembershipLevel = 'Admin';

-- Reset other known passwords (update these with your actual passwords)
-- Example:
-- UPDATE USERS SET [Password] = 'password123' WHERE UserName = 'testuser';

-- Show all users so you can manually reset passwords if needed
SELECT 
    CustomerID,
    UserName,
    Email,
    MembershipLevel,
    'Password has been reset - please update manually if needed' AS Note
FROM USERS;

PRINT 'Admin password reset to: admin1290';
PRINT 'Other users: Please update their passwords manually in this script';
GO
