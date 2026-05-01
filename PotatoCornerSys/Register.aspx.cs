using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string username = txtUsername.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();
            string password = txtPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            if (string.IsNullOrEmpty(name) ||
                string.IsNullOrEmpty(email) ||
                string.IsNullOrEmpty(username) ||
                string.IsNullOrEmpty(phone) ||
                string.IsNullOrEmpty(address) ||
                string.IsNullOrEmpty(password) ||
                string.IsNullOrEmpty(confirmPassword))
            {
                lblMessage.Text = "Please fill in all fields.";
                lblMessage.CssClass = "error-msg";
                lblMessage.Visible = true;
                return;
            }

            if (password != confirmPassword)
            {
                lblMessage.Text = "Passwords do not match.";
                lblMessage.CssClass = "error-msg";
                lblMessage.Visible = true;
                return;
            }

            // Database INSERT query to register new customer
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // First check if username or email already exists
                    string checkQuery = "SELECT COUNT(*) FROM USERS WHERE UserName = @Username OR Email = @Email";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@Username", username);
                        checkCmd.Parameters.AddWithValue("@Email", email);

                        int existingCount = (int)checkCmd.ExecuteScalar();
                        if (existingCount > 0)
                        {
                            lblMessage.Text = "Username or email already exists. Please choose different ones.";
                            lblMessage.CssClass = "error-msg";
                            lblMessage.Visible = true;
                            return;
                        }
                    }

                    // INSERT query from Required_10_Queries.sql (Query #1)
                    string insertQuery = @"
                        INSERT INTO USERS (UserName, Fullname, [Address], Email, PhoneNumber, [Password], Points, MembershipLevel)
                        VALUES (@Username, @Fullname, @Address, @Email, @Phone, @Password, 0, 'Regular')";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Username", username);
                        cmd.Parameters.AddWithValue("@Fullname", name);
                        cmd.Parameters.AddWithValue("@Address", address);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Phone", phone);
                        cmd.Parameters.AddWithValue("@Password", password); // In production, hash the password

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            // Registration successful
                            lblMessage.Text = "Registration successful! You can now login with your credentials.";
                            lblMessage.CssClass = "success-msg";
                            lblMessage.Visible = true;

                            // Clear form fields
                            txtName.Text = "";
                            txtEmail.Text = "";
                            txtUsername.Text = "";
                            txtPhone.Text = "";
                            txtAddress.Text = "";
                            txtPassword.Text = "";
                            txtConfirmPassword.Text = "";

                            // Optional: Auto-redirect to login after 3 seconds
                            Response.AddHeader("REFRESH", "3;URL=Login.aspx");
                        }
                        else
                        {
                            lblMessage.Text = "Registration failed. Please try again.";
                            lblMessage.CssClass = "error-msg";
                            lblMessage.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Handle database errors - show actual error for debugging
                lblMessage.Text = "Database Error: " + ex.Message;
                lblMessage.CssClass = "error-msg";
                lblMessage.Visible = true;

                // Also log inner exception if exists
                if (ex.InnerException != null)
                {
                    lblMessage.Text += "<br/>Inner Error: " + ex.InnerException.Message;
                }
            }
        }

        protected void lnkLogin_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Login.aspx");
        }
    }
}