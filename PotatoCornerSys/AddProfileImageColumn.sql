-- Add ProfileImagePath column to Membership table
-- This will store the file path of uploaded profile images

USE PotatoCornerDB;
GO

-- Check if column already exists before adding
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'dbo.Membership') 
    AND name = 'ProfileImagePath'
)
BEGIN
    ALTER TABLE Membership
    ADD ProfileImagePath NVARCHAR(500) NULL;
    
    PRINT 'ProfileImagePath column added successfully to Membership table.';
END
ELSE
BEGIN
    PRINT 'ProfileImagePath column already exists in Membership table.';
END
GO
