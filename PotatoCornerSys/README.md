# Potato Corner POS System

A comprehensive Point of Sale (POS) system for Potato Corner franchise built with ASP.NET Web Forms and SQL Server.

## 🎯 Features

### Core Functionality
- **Order Management**: Complete POS interface for placing orders with multiple products (French Fries, Chicken Pops, Loopys)
- **Customer Management**: User registration, login, and profile management
- **Royalty Membership**: Membership registration with 10% discount benefits
- **Order Tracking**: Real-time order status tracking with automatic status updates
- **Payment Processing**: Multiple payment methods (GoTyme, Maya Bank, GCash, Points)
- **Delivery Options**: Walk-in with pickup time selection and delivery with fee

### Product Features
- Multiple size options (Regular, Large, Jumbo, Mega, Giga, Terra)
- Multiple flavor options (Sour Cream, BBQ, Cheese, Salt)
- Dynamic pricing based on size and quantity
- Shopping cart with add/remove functionality

### User Features
- **Profile Page**: View order history, track orders, reorder previous orders
- **Order Search**: Search orders by Order ID
- **Order Cancellation**: Cancel orders within 5-minute window
- **Points System**: Earn 2 points for every PHP 500 spent
- **Membership Benefits**: 10% discount for royalty members

### Admin Features
- **Order Summary Dashboard**: View all orders with filtering options
- **Database Backup**: Full backup and restore functionality
- **CSV Export**: Export orders and users data

## 🔒 Security Features

### Required Security Implementation
✅ **Backup/Recovery Mechanism**
- Full database backup (.BAK files)
- CSV export for Orders and Users
- Database restore functionality
- Backup history tracking

### Additional Security Features
✅ **Input Validation**
- Name validation (no numbers allowed)
- Phone number validation (numbers only)
- Address validation (letters, numbers, spaces, commas)
- File upload validation (type and size)
- Payment amount validation

✅ **Session Management & History Transactions**
- Secure user authentication
- Session-based cart management
- Complete order history tracking
- Transaction audit trail

✅ **SQL Injection Prevention**
- Parameterized queries throughout the system
- Safe database operations

## 📊 Database

### Tables
- **USERS**: Customer accounts and information
- **Orders**: Order transactions with status tracking
- **OrderItems**: Individual items in each order
- **Products**: Product catalog
- **ProductSizes**: Available sizes for each product
- **ProductFlavors**: Available flavors for each product
- **Membership**: Royalty membership records

### SQL Queries
The system implements **18 SQL queries** including:
- INSERT queries (orders, users, membership)
- SELECT queries with JOINs (order history, product details)
- UPDATE queries (order status, customer points)
- DELETE queries (clear history)
- SEARCH and FILTER queries
- AGGREGATE queries (order statistics)

See [SQL_QUERIES_DOCUMENTATION.md](SQL_QUERIES_DOCUMENTATION.md) for complete documentation.

## 🛠️ Technology Stack

- **Framework**: ASP.NET Web Forms (.NET Framework)
- **Database**: SQL Server (PotatoCorner_DB)
- **Language**: C#
- **Frontend**: HTML, CSS, JavaScript
- **AJAX**: UpdatePanel for smooth user experience

## 📁 Project Structure

```
PotatoCornerSys/
├── Default.aspx              # Home page
├── Login.aspx                # User login
├── Register.aspx             # User registration
├── Order.aspx                # POS ordering interface
├── Profile.aspx              # User profile and order history
├── Receipt.aspx              # Order receipt
├── Membership.aspx           # Membership information
├── RegisterForm.aspx         # Royalty membership registration
├── OrderSummary.aspx         # Admin order dashboard
├── DatabaseBackup.aspx       # Backup/restore functionality
├── InitializeDatabase.sql    # Database setup script
├── CreateMembershipTable.sql # Membership table script
├── SECURITY_DOCUMENTATION.md # Security features documentation
└── SQL_QUERIES_DOCUMENTATION.md # SQL queries documentation
```

## 🚀 Setup Instructions

### Prerequisites
- Visual Studio 2019 or later
- SQL Server 2016 or later
- .NET Framework 4.7.2 or later

### Database Setup
1. Open SQL Server Management Studio
2. Run `InitializeDatabase.sql` to create the database and tables
3. Run `CreateMembershipTable.sql` to create the membership table
4. Update connection string in `Web.config`:
   ```xml
   <connectionStrings>
     <add name="PotatoCornerDB" 
          connectionString="Data Source=YOUR_SERVER;Initial Catalog=PotatoCorner_DB;Integrated Security=True" 
          providerName="System.Data.SqlClient" />
   </connectionStrings>
   ```

### Running the Application
1. Open `PotatoCornerSys.sln` in Visual Studio
2. Build the solution (Ctrl + Shift + B)
3. Run the application (F5)
4. Navigate to `Default.aspx` to start

## 📖 Documentation

- [Security Documentation](SECURITY_DOCUMENTATION.md) - Complete security implementation details
- [SQL Queries Documentation](SQL_QUERIES_DOCUMENTATION.md) - All SQL queries used in the system

## 👥 User Roles

### Customer
- Browse menu and place orders
- Track order status
- View order history
- Register for royalty membership
- Earn and use loyalty points

### Admin
- View all orders
- Filter orders by delivery type
- Export data to CSV
- Backup and restore database

## 🎨 UI Features

- Responsive design with modern gradient styling
- Smooth AJAX updates (no page refresh for quantity changes)
- Scroll position maintenance during postbacks
- Professional modal dialogs
- Real-time cart updates
- Color-coded order status indicators

## 📝 License

This project is created for educational purposes.

## 👨‍💻 Author

**Rheyle**

---

**Last Updated**: April 29, 2026  
**Version**: 1.0
