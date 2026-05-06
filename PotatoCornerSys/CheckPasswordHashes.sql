-- Check current password hashes in database
USE PotatoCornerDB;
GO

SELECT 
    CustomerID,
    UserName,
    Email,
    [Password],
    LEN([Password]) AS PasswordLength
FROM USERS
ORDER BY CustomerID;
GO
