using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace PotatoCornerSys
{
    public partial class TestDatabase : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnTest_Click(object sender, EventArgs e)
        {
            StringBuilder results = new StringBuilder();
            
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                results.AppendLine("<div class='result success'>Connection string found: " + connectionString + "</div>");

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    results.AppendLine("<div class='result success'>Database connection successful!</div>");

                    // Test if USERS table exists
                    string checkUsersQuery = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'USERS'";
                    using (SqlCommand cmd = new SqlCommand(checkUsersQuery, conn))
                    {
                        int usersTableExists = (int)cmd.ExecuteScalar();
                        results.AppendLine("<div class='result " + (usersTableExists > 0 ? "success" : "error") + "'>USERS table exists: " + (usersTableExists > 0 ? "YES" : "NO") + "</div>");
                    }

                    // Test if Membership table exists
                    string checkMembershipQuery = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Membership'";
                    using (SqlCommand cmd = new SqlCommand(checkMembershipQuery, conn))
                    {
                        int membershipTableExists = (int)cmd.ExecuteScalar();
                        results.AppendLine("<div class='result " + (membershipTableExists > 0 ? "success" : "error") + "'>Membership table exists: " + (membershipTableExists > 0 ? "YES" : "NO") + "</div>");
                    }

                    // Check Membership table structure specifically
                    try
                    {
                        string checkMembershipColumnsQuery = @"
                            SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH, COLUMN_DEFAULT
                            FROM INFORMATION_SCHEMA.COLUMNS 
                            WHERE TABLE_NAME = 'Membership' 
                            ORDER BY ORDINAL_POSITION";
                        
                        using (SqlCommand cmd = new SqlCommand(checkMembershipColumnsQuery, conn))
                        {
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                results.AppendLine("<div class='result'>Membership table columns:</div>");
                                results.AppendLine("<div class='result'>");
                                while (reader.Read())
                                {
                                    string columnInfo = $"- {reader["COLUMN_NAME"]} ({reader["DATA_TYPE"]}";
                                    if (reader["CHARACTER_MAXIMUM_LENGTH"] != DBNull.Value)
                                        columnInfo += $"({reader["CHARACTER_MAXIMUM_LENGTH"]})";
                                    columnInfo += $", Nullable: {reader["IS_NULLABLE"]}";
                                    if (reader["COLUMN_DEFAULT"] != DBNull.Value)
                                        columnInfo += $", Default: {reader["COLUMN_DEFAULT"]}";
                                    columnInfo += ")<br/>";
                                    results.AppendLine(columnInfo);
                                }
                                results.AppendLine("</div>");
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        results.AppendLine("<div class='result error'>Error checking Membership table structure: " + ex.Message + "</div>");
                    }

                    // Try to create Membership table
                    try
                    {
                        string createTableQuery = @"
                            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Membership' AND xtype='U')
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
                                CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
                            )";

                        using (SqlCommand cmd = new SqlCommand(createTableQuery, conn))
                        {
                            cmd.ExecuteNonQuery();
                            results.AppendLine("<div class='result success'>Membership table creation attempted successfully!</div>");
                        }
                    }
                    catch (Exception ex)
                    {
                        results.AppendLine("<div class='result error'>Error creating Membership table: " + ex.Message + "</div>");
                    }

                    // Test session data
                    if (Session["CustomerID"] != null)
                    {
                        results.AppendLine("<div class='result success'>Session CustomerID: " + Session["CustomerID"].ToString() + "</div>");
                    }
                    else
                    {
                        results.AppendLine("<div class='result error'>No CustomerID in session - user not logged in</div>");
                    }
                }
            }
            catch (Exception ex)
            {
                results.AppendLine("<div class='result error'>Database connection failed: " + ex.Message + "</div>");
                if (ex.InnerException != null)
                {
                    results.AppendLine("<div class='result error'>Inner exception: " + ex.InnerException.Message + "</div>");
                }
            }

            litResults.Text = results.ToString();
        }
    }
}