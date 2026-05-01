-- Create Membership table for royalty program
CREATE TABLE Membership (
    MembershipID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    MembershipType NVARCHAR(50) NOT NULL DEFAULT 'Royalty',
    RegistrationDate DATETIME NOT NULL DEFAULT GETDATE(),
    RegistrationFee DECIMAL(10,2) NOT NULL DEFAULT 100.00,
    PaymentMethod NVARCHAR(50) NOT NULL,
    RoyaltyNumber NVARCHAR(10) NOT NULL UNIQUE,
    ProfilePicture NVARCHAR(255) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES USERS(CustomerID)
);

-- Create index for faster lookups
CREATE INDEX IX_Membership_CustomerID ON Membership(CustomerID);
CREATE INDEX IX_Membership_RoyaltyNumber ON Membership(RoyaltyNumber);

-- Add sample data if needed (optional)
-- INSERT INTO Membership (CustomerID, MembershipType, RegistrationDate, RegistrationFee, PaymentMethod, RoyaltyNumber, ProfilePicture)
-- VALUES (1, 'Royalty', GETDATE(), 100.00, 'GCash', 'PC12345', '~/Uploads/PC12345.jpg');