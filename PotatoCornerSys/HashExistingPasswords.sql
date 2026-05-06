-- Hash all existing plain text passwords in the USERS table
-- This script will convert all passwords to SHA256 hashes
-- IMPORTANT: Run this script ONLY ONCE after deploying the password hashing code

USE PotatoCornerDB;
GO

-- Create a temporary table to store the hashed passwords
CREATE TABLE #TempHashedPasswords (
    CustomerID INT,
    HashedPassword NVARCHAR(64)
);

-- Note: SQL Server doesn't have built-in SHA256, so we need to use HASHBYTES with SHA2_256
-- Insert hashed passwords into temp table
INSERT INTO #TempHashedPasswords (CustomerID, HashedPassword)
SELECT 
    CustomerID,
    LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', [Password]), 2)) AS HashedPassword
FROM USERS
WHERE LEN([Password]) < 64; -- Only hash passwords that aren't already hashed (plain text passwords are typically shorter)

-- Display what will be updated (for verification)
SELECT 
    u.CustomerID,
    u.UserName,
    u.Email,
    'Plain: ' + u.[Password] AS OldPassword,
    'Hashed: ' + t.HashedPassword AS NewPassword
FROM USERS u
INNER JOIN #TempHashedPasswords t ON u.CustomerID = t.CustomerID;

-- Update the passwords with hashed versions
UPDATE u
SET u.[Password] = t.HashedPassword
FROM USERS u
INNER JOIN #TempHashedPasswords t ON u.CustomerID = t.CustomerID;

-- Show results
PRINT 'Password hashing completed.';
PRINT 'Total passwords hashed: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

-- Clean up
DROP TABLE #TempHashedPasswords;
GO

-- Verify all passwords are now 64 characters (SHA256 hash length)
SELECT 
    CustomerID,
    UserName,
    Email,
    LEN([Password]) AS PasswordLength,
    CASE 
        WHEN LEN([Password]) = 64 THEN 'Hashed'
        ELSE 'Plain Text (ERROR)'
    END AS Status
FROM USERS;
GO
