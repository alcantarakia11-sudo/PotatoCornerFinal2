using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;

namespace PotatoCornerSys
{
    public partial class DatabaseBackup : System.Web.UI.Page
    {
        private string backupFolder = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Set backup folder path
            backupFolder = Server.MapPath("~/Backups/");

            // Create backup folder if it doesn't exist
            if (!Directory.Exists(backupFolder))
            {
                Directory.CreateDirectory(backupFolder);
            }

            if (!IsPostBack)
            {
                LoadBackupHistory();
            }
        }

        protected void btnBackup_Click(object sender, EventArgs e)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                
                // Generate backup filename with timestamp
                string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
                string backupFileName = $"PotatoCorner_Backup_{timestamp}.bak";
                string backupPath = Path.Combine(backupFolder, backupFileName);

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // SQL Server backup command
                    string backupQuery = $@"
                        BACKUP DATABASE [PotatoCorner_DB] 
                        TO DISK = '{backupPath}' 
                        WITH FORMAT, 
                        MEDIANAME = 'PotatoCornerBackup',
                        NAME = 'Full Backup of PotatoCorner_DB';";

                    using (SqlCommand cmd = new SqlCommand(backupQuery, conn))
                    {
                        cmd.CommandTimeout = 300; // 5 minutes timeout
                        cmd.ExecuteNonQuery();
                    }
                }

                ShowMessage(lblBackupMessage, $"✓ Backup created successfully: {backupFileName}", "success");
                LoadBackupHistory();
            }
            catch (Exception ex)
            {
                ShowMessage(lblBackupMessage, $"✗ Backup failed: {ex.Message}", "error");
            }
        }

        protected void btnExportOrders_Click(object sender, EventArgs e)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT 
                            o.OrderID,
                            o.OrderDate,
                            u.Fullname as CustomerName,
                            u.Email,
                            u.PhoneNumber,
                            o.DeliveryType,
                            o.TotalAmount,
                            o.OrderStatus,
                            o.PaymentMethod
                        FROM Orders o
                        INNER JOIN USERS u ON o.CustomerID = u.CustomerID
                        ORDER BY o.OrderDate DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            StringBuilder csv = new StringBuilder();
                            
                            // Add headers
                            csv.AppendLine("OrderID,OrderDate,CustomerName,Email,PhoneNumber,DeliveryType,TotalAmount,OrderStatus,PaymentMethod");

                            // Add data rows
                            while (reader.Read())
                            {
                                csv.AppendLine($"{reader["OrderID"]}," +
                                    $"{reader["OrderDate"]}," +
                                    $"\"{reader["CustomerName"]}\"," +
                                    $"{reader["Email"]}," +
                                    $"{reader["PhoneNumber"]}," +
                                    $"{reader["DeliveryType"]}," +
                                    $"{reader["TotalAmount"]}," +
                                    $"{reader["OrderStatus"]}," +
                                    $"{reader["PaymentMethod"]}");
                            }

                            // Download CSV file
                            string filename = $"Orders_Export_{DateTime.Now:yyyyMMdd_HHmmss}.csv";
                            Response.Clear();
                            Response.ContentType = "text/csv";
                            Response.AddHeader("Content-Disposition", $"attachment; filename={filename}");
                            Response.Write(csv.ToString());
                            Response.End();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage(lblExportMessage, $"✗ Export failed: {ex.Message}", "error");
            }
        }

        protected void btnExportUsers_Click(object sender, EventArgs e)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT 
                            CustomerID,
                            UserName,
                            Fullname,
                            Email,
                            PhoneNumber,
                            Address,
                            Points,
                            MembershipLevel,
                            CreatedDate
                        FROM USERS
                        ORDER BY CreatedDate DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            StringBuilder csv = new StringBuilder();
                            
                            // Add headers
                            csv.AppendLine("CustomerID,UserName,Fullname,Email,PhoneNumber,Address,Points,MembershipLevel,CreatedDate");

                            // Add data rows
                            while (reader.Read())
                            {
                                csv.AppendLine($"{reader["CustomerID"]}," +
                                    $"{reader["UserName"]}," +
                                    $"\"{reader["Fullname"]}\"," +
                                    $"{reader["Email"]}," +
                                    $"{reader["PhoneNumber"]}," +
                                    $"\"{reader["Address"]}\"," +
                                    $"{reader["Points"]}," +
                                    $"{reader["MembershipLevel"]}," +
                                    $"{reader["CreatedDate"]}");
                            }

                            // Download CSV file
                            string filename = $"Users_Export_{DateTime.Now:yyyyMMdd_HHmmss}.csv";
                            Response.Clear();
                            Response.ContentType = "text/csv";
                            Response.AddHeader("Content-Disposition", $"attachment; filename={filename}");
                            Response.Write(csv.ToString());
                            Response.End();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage(lblExportMessage, $"✗ Export failed: {ex.Message}", "error");
            }
        }

        protected void btnRestore_Click(object sender, EventArgs e)
        {
            try
            {
                if (!fileRestore.HasFile)
                {
                    ShowMessage(lblRestoreMessage, "✗ Please select a backup file to restore.", "error");
                    return;
                }

                // Validate file extension
                string fileExtension = Path.GetExtension(fileRestore.FileName).ToLower();
                if (fileExtension != ".bak")
                {
                    ShowMessage(lblRestoreMessage, "✗ Invalid file type. Please select a .bak file.", "error");
                    return;
                }

                // Save uploaded file temporarily
                string tempPath = Path.Combine(backupFolder, "temp_restore.bak");
                fileRestore.SaveAs(tempPath);

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Restore database
                    string restoreQuery = $@"
                        USE master;
                        ALTER DATABASE [PotatoCorner_DB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
                        RESTORE DATABASE [PotatoCorner_DB] 
                        FROM DISK = '{tempPath}' 
                        WITH REPLACE;
                        ALTER DATABASE [PotatoCorner_DB] SET MULTI_USER;";

                    using (SqlCommand cmd = new SqlCommand(restoreQuery, conn))
                    {
                        cmd.CommandTimeout = 300; // 5 minutes timeout
                        cmd.ExecuteNonQuery();
                    }
                }

                // Delete temporary file
                if (File.Exists(tempPath))
                {
                    File.Delete(tempPath);
                }

                ShowMessage(lblRestoreMessage, "✓ Database restored successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowMessage(lblRestoreMessage, $"✗ Restore failed: {ex.Message}", "error");
            }
        }

        private void LoadBackupHistory()
        {
            try
            {
                DirectoryInfo dir = new DirectoryInfo(backupFolder);
                FileInfo[] files = dir.GetFiles("*.bak");

                if (files.Length == 0)
                {
                    litBackupHistory.Text = "<div class='info message'>No backups found. Create your first backup above.</div>";
                    return;
                }

                StringBuilder html = new StringBuilder();
                
                // Sort by date descending
                Array.Sort(files, (x, y) => y.LastWriteTime.CompareTo(x.LastWriteTime));

                foreach (FileInfo file in files)
                {
                    html.AppendLine("<div class='backup-item'>");
                    html.AppendLine("  <div class='backup-info'>");
                    html.AppendLine($"    <div class='backup-name'>{file.Name}</div>");
                    html.AppendLine($"    <div class='backup-date'>Created: {file.LastWriteTime:MMM dd, yyyy h:mm tt} | Size: {FormatFileSize(file.Length)}</div>");
                    html.AppendLine("  </div>");
                    html.AppendLine("</div>");
                }

                litBackupHistory.Text = html.ToString();
            }
            catch (Exception ex)
            {
                litBackupHistory.Text = $"<div class='error message'>Error loading backup history: {ex.Message}</div>";
            }
        }

        private string FormatFileSize(long bytes)
        {
            string[] sizes = { "B", "KB", "MB", "GB" };
            double len = bytes;
            int order = 0;
            
            while (len >= 1024 && order < sizes.Length - 1)
            {
                order++;
                len = len / 1024;
            }

            return $"{len:0.##} {sizes[order]}";
        }

        private void ShowMessage(System.Web.UI.WebControls.Label label, string message, string type)
        {
            label.Text = message;
            label.CssClass = $"message {type}";
            label.Visible = true;
        }
    }
}