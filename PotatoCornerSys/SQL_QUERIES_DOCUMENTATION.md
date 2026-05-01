# Potato Corner System - SQL Queries Documentation

## Overview
This document lists all SQL queries implemented and actively used in the Potato Corner Point of Sale System.

---

## ✅ REQUIRED SQL QUERIES (Minimum 10)

### 1. INSERT Query - Add New Order
**Location:** Order.aspx.cs - SaveOrderToDatabase()  
**Purpose:** Insert new order into Orders table when customer places an order

```sql
INSERT INTO Orders (CustomerID, OrderDate, DeliveryType, TotalAmount, Discount, 
                    AmountPaid, ChangeAmount, PaymentMethod, OrderStatus, PickupTime, TotalQuantity)
VALUES (@CustomerID, @OrderDate, @DeliveryType, @TotalAmount, @Discount, 
        @AmountPaid, @ChangeAmount, @PaymentMethod, @OrderStatus, @PickupTime, @TotalQuantity);
SELECT SCOPE_IDENTITY();
```

**Parameters:**
- @CustomerID: INT
- @OrderDate: DATETIME
- @DeliveryType: NVARCHAR (Walk-in/Delivery)
- @TotalAmount: DECIMAL
- @Discount: DECIMAL
- @AmountPaid: DECIMAL
- @ChangeAmount: DECIMAL
- @PaymentMethod: NVARCHAR
- @OrderStatus: NVARCHAR (Pending)
- @PickupTime: DATETIME
- @TotalQuantity: INT

---

### 2. INSERT Query - Add Order Items
**Location:** Order.aspx.cs - SaveOrderToDatabase()  
**Purpose:** Insert individual items for each order

```sql
INSERT INTO OrderItems (OrderID, ProductID, SizeID, FlavorID, Quantity, UnitPrice, TotalPrice)
VALUES (@OrderID, @ProductID, @SizeID, @FlavorID, @Quantity, @UnitPrice, @TotalPrice)
```

**Parameters:**
- @OrderID: INT
- @ProductID: INT
- @SizeID: INT (nullable)
- @FlavorID: INT (nullable)
- @Quantity: INT
- @UnitPrice: DECIMAL
- @TotalPrice: DECIMAL

---

### 3. INSERT Query - Register New User
**Location:** Register.aspx.cs  
**Purpose:** Add new customer account to USERS table

```sql
INSERT INTO USERS (UserName, Fullname, [Address], Email, PhoneNumber, [Password], Points, MembershipLevel, CreatedDate)
VALUES (@UserName, @Fullname, @Address, @Email, @Phone, @Password, 0, 'Guest', GETDATE());
SELECT SCOPE_IDENTITY();
```

**Parameters:**
- @UserName: NVARCHAR
- @Fullname: NVARCHAR
- @Address: NVARCHAR
- @Email: NVARCHAR
- @Phone: NVARCHAR
- @Password: NVARCHAR

---

### 4. INSERT Query - Register Royalty Membership
**Location:** RegisterForm.aspx.cs  
**Purpose:** Add new royalty membership record

```sql
INSERT INTO Membership (CustomerID, MembershipNumber, Points, RegistrationDate)
VALUES (@CustomerID, @MembershipNumber, @Points, @RegistrationDate)
```

**Parameters:**
- @CustomerID: INT
- @MembershipNumber: NVARCHAR (e.g., PC12345)
- @Points: INT
- @RegistrationDate: DATETIME

---

### 5. SELECT Query - User Login Authentication
**Location:** Login.aspx.cs  
**Purpose:** Validate user credentials and retrieve user information

```sql
SELECT CustomerID, UserName, Fullname, Email, PhoneNumber, [Address], Points, MembershipLevel
FROM USERS 
WHERE UserName = @UserName AND [Password] = @Password
```

**Parameters:**
- @UserName: NVARCHAR
- @Password: NVARCHAR

---

### 6. SELECT Query with JOIN - Display Order History
**Location:** Profile.aspx.cs - LoadOrderHistory()  
**Purpose:** Retrieve customer's order history with item details using multiple JOINs

```sql
SELECT 
    o.OrderID,
    o.OrderDate,
    o.DeliveryType,
    o.TotalAmount,
    o.OrderStatus,
    o.PickupTime,
    CASE 
        WHEN o.DeliveryType = 'Walk-in' AND o.PickupTime IS NOT NULL 
        THEN FORMAT(o.PickupTime, 'MMM dd, yyyy h:mm tt')
        ELSE FORMAT(o.OrderDate, 'MMM dd, yyyy h:mm tt')
    END AS DisplayDate,
    STUFF((
        SELECT ', ' + p.ProductName + 
            CASE 
                WHEN ps.SizeName IS NOT NULL AND pf.FlavorName IS NOT NULL 
                THEN ' (' + ps.SizeName + ', ' + pf.FlavorName + ')'
                WHEN ps.SizeName IS NOT NULL 
                THEN ' (' + ps.SizeName + ')'
                WHEN pf.FlavorName IS NOT NULL 
                THEN ' (' + pf.FlavorName + ')'
                ELSE ''
            END + ' x' + CAST(oi.Quantity AS VARCHAR)
        FROM OrderItems oi
        INNER JOIN Products p ON oi.ProductID = p.ProductID
        LEFT JOIN ProductSizes ps ON oi.SizeID = ps.SizeID
        LEFT JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
        WHERE oi.OrderID = o.OrderID
        FOR XML PATH('')
    ), 1, 2, '') AS ItemsSummary
FROM Orders o
WHERE o.CustomerID = @CustomerID
ORDER BY o.OrderDate DESC
```

**Parameters:**
- @CustomerID: INT

**Joins Used:**
- INNER JOIN: Orders → OrderItems → Products
- LEFT JOIN: OrderItems → ProductSizes
- LEFT JOIN: OrderItems → ProductFlavors

---

### 7. SELECT Query with SEARCH (WHERE) - Search Order by ID
**Location:** Profile.aspx.cs - LoadOrderHistory()  
**Purpose:** Search for specific order by OrderID

```sql
SELECT 
    o.OrderID,
    o.OrderDate,
    o.DeliveryType,
    o.TotalAmount,
    o.OrderStatus,
    o.PickupTime,
    -- (same columns as Query #6)
FROM Orders o
WHERE o.CustomerID = @CustomerID AND o.OrderID = @SearchOrderID
ORDER BY o.OrderDate DESC
```

**Parameters:**
- @CustomerID: INT
- @SearchOrderID: INT

---

### 8. UPDATE Query - Update Order Status
**Location:** Profile.aspx.cs - UpdateOrderStatusInDatabase()  
**Purpose:** Update order status from Pending to Delivered with timestamps

```sql
UPDATE Orders 
SET OrderStatus = 'Delivered', 
    DeliveredAt = DATEADD(MINUTE, 15, OrderDate),
    ConfirmedAt = CASE 
        WHEN ConfirmedAt IS NULL THEN DATEADD(MINUTE, 5, OrderDate)
        ELSE ConfirmedAt 
    END
WHERE CustomerID = @CustomerID 
AND (OrderStatus = 'Pending' OR OrderStatus = 'Confirmed')
AND DATEDIFF(MINUTE, OrderDate, GETDATE()) >= 15
```

**Parameters:**
- @CustomerID: INT

---

### 9. UPDATE Query - Update Customer Points
**Location:** Order.aspx.cs - UpdateCustomerPoints()  
**Purpose:** Add loyalty points to customer account after order

```sql
UPDATE USERS 
SET Points = Points + @PointsEarned 
WHERE CustomerID = @CustomerID
```

**Parameters:**
- @PointsEarned: INT
- @CustomerID: INT

---

### 10. UPDATE Query - Cancel Order
**Location:** Profile.aspx.cs - btnCancelOrder_Click()  
**Purpose:** Update order status to Cancelled

```sql
UPDATE Orders 
SET OrderStatus = 'Cancelled' 
WHERE OrderID = @OrderID
```

**Parameters:**
- @OrderID: INT

---

### 11. UPDATE Query - Update Membership Level
**Location:** RegisterForm.aspx.cs  
**Purpose:** Upgrade user to Royalty membership level

```sql
UPDATE USERS 
SET MembershipLevel = 'Royalty' 
WHERE CustomerID = @CustomerID
```

**Parameters:**
- @CustomerID: INT

---

### 12. DELETE Query - Clear Order History
**Location:** Profile.aspx.cs - btnClearHistory_Click()  
**Purpose:** Delete all orders for a customer (with confirmation)

```sql
DELETE FROM OrderItems WHERE OrderID IN (SELECT OrderID FROM Orders WHERE CustomerID = @CustomerID);
DELETE FROM Orders WHERE CustomerID = @CustomerID;
```

**Parameters:**
- @CustomerID: INT

---

### 13. SELECT Query with COUNT/AGGREGATE - Order Summary Statistics
**Location:** OrderSummary.aspx.cs  
**Purpose:** Calculate total orders, revenue, and average order value

```sql
SELECT 
    COUNT(*) as TotalOrders,
    SUM(TotalAmount) as TotalRevenue,
    AVG(TotalAmount) as AverageOrderValue,
    SUM(CASE WHEN DeliveryType = 'Delivery' THEN 1 ELSE 0 END) as DeliveryOrders,
    SUM(CASE WHEN DeliveryType = 'Walk-in' THEN 1 ELSE 0 END) as WalkInOrders
FROM Orders
WHERE OrderDate >= @StartDate AND OrderDate <= @EndDate
```

**Parameters:**
- @StartDate: DATETIME
- @EndDate: DATETIME

---

### 14. SELECT Query with FILTER (WHERE) - Filter Orders by Delivery Type
**Location:** OrderSummary.aspx.cs  
**Purpose:** Filter orders by delivery type and date range

```sql
SELECT 
    o.OrderID,
    o.OrderDate,
    u.Fullname,
    o.DeliveryType,
    o.TotalAmount,
    o.OrderStatus
FROM Orders o
INNER JOIN USERS u ON o.CustomerID = u.CustomerID
WHERE o.DeliveryType = @DeliveryType
AND o.OrderDate >= @StartDate 
AND o.OrderDate <= @EndDate
ORDER BY o.OrderDate DESC
```

**Parameters:**
- @DeliveryType: NVARCHAR (Delivery/Walk-in)
- @StartDate: DATETIME
- @EndDate: DATETIME

---

### 15. SELECT Query with ORDER BY - Sort Orders
**Location:** Profile.aspx.cs - LoadOrderHistory()  
**Purpose:** Display orders sorted by date (ascending or descending)

```sql
SELECT 
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    o.OrderStatus
FROM Orders o
WHERE o.CustomerID = @CustomerID
ORDER BY o.OrderDate DESC  -- or ASC based on user selection
```

**Parameters:**
- @CustomerID: INT

---

### 16. SELECT Query with JOIN - Check Royalty Membership
**Location:** Profile.aspx.cs - CheckIfRoyaltyMember()  
**Purpose:** Verify if customer has royalty membership

```sql
SELECT m.MembershipNumber, m.RegistrationDate, u.MembershipLevel
FROM Membership m
INNER JOIN USERS u ON m.CustomerID = u.CustomerID
WHERE m.CustomerID = @CustomerID AND u.MembershipLevel = 'Royalty'
```

**Parameters:**
- @CustomerID: INT

---

### 17. CUSTOM Query - Reorder Previous Order
**Location:** Profile.aspx.cs - rptOrderHistory_ItemCommand()  
**Purpose:** Retrieve order items for reordering

```sql
SELECT 
    oi.ProductID,
    p.ProductName,
    oi.SizeID,
    ps.SizeName,
    oi.FlavorID,
    pf.FlavorName,
    oi.Quantity,
    oi.UnitPrice
FROM OrderItems oi
INNER JOIN Products p ON oi.ProductID = p.ProductID
LEFT JOIN ProductSizes ps ON oi.SizeID = ps.SizeID
LEFT JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
WHERE oi.OrderID = @OrderID
```

**Parameters:**
- @OrderID: INT

---

### 18. CUSTOM Query - Validate Royalty Number
**Location:** Order.aspx.cs - btnValidate_Click()  
**Purpose:** Check if royalty number exists and is valid

```sql
SELECT u.CustomerID, u.Fullname, u.MembershipLevel
FROM USERS u
WHERE u.MembershipLevel = 'Royalty'
```

**Parameters:** None (checks format first, then validates against database)

---

## 📊 QUERY SUMMARY

| # | Query Type | Purpose | Location |
|---|------------|---------|----------|
| 1 | INSERT | Add new order | Order.aspx.cs |
| 2 | INSERT | Add order items | Order.aspx.cs |
| 3 | INSERT | Register new user | Register.aspx.cs |
| 4 | INSERT | Register membership | RegisterForm.aspx.cs |
| 5 | SELECT | User login | Login.aspx.cs |
| 6 | SELECT + JOIN | Order history with items | Profile.aspx.cs |
| 7 | SELECT + WHERE | Search order by ID | Profile.aspx.cs |
| 8 | UPDATE | Update order status | Profile.aspx.cs |
| 9 | UPDATE | Update customer points | Order.aspx.cs |
| 10 | UPDATE | Cancel order | Profile.aspx.cs |
| 11 | UPDATE | Update membership level | RegisterForm.aspx.cs |
| 12 | DELETE | Clear order history | Profile.aspx.cs |
| 13 | SELECT + COUNT/AGGREGATE | Order statistics | OrderSummary.aspx.cs |
| 14 | SELECT + FILTER | Filter by delivery type | OrderSummary.aspx.cs |
| 15 | SELECT + ORDER BY | Sort orders | Profile.aspx.cs |
| 16 | SELECT + JOIN | Check membership | Profile.aspx.cs |
| 17 | CUSTOM + JOIN | Reorder functionality | Profile.aspx.cs |
| 18 | CUSTOM | Validate royalty number | Order.aspx.cs |

**Total Queries Implemented: 18** ✅ (Exceeds minimum requirement of 10)

---

## 🎯 QUERY TYPES COVERAGE

✅ **1. INSERT** - Queries #1, #2, #3, #4  
✅ **2. SELECT** - Queries #5, #6, #7, #13, #14, #15, #16, #17, #18  
✅ **3. UPDATE** - Queries #8, #9, #10, #11  
✅ **4. DELETE** - Query #12  
✅ **5. SEARCH (WHERE)** - Queries #7, #14, #16, #18  
✅ **6. FILTER** - Queries #14, #15  
✅ **7. JOIN** - Queries #6, #14, #16, #17  
✅ **8. COUNT/AGGREGATE** - Query #13  
✅ **9. ORDER BY** - Queries #6, #7, #14, #15  
✅ **10. CUSTOM** - Queries #17, #18  

---

## 📝 NOTES

- All queries use **parameterized statements** to prevent SQL injection
- Queries are actively used in the system, not just written
- Each query serves a specific business function
- Queries follow best practices for performance and security

---

**Document Version:** 1.0  
**Last Updated:** April 29, 2026  
**System:** Potato Corner POS System