using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            // Clear all previous field errors first
            ClearAllErrors();

            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string username = txtUsername.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();
            string password = txtPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            bool hasError = false;

            // ── FULL NAME ──────────────────────────────────────────
            if (string.IsNullOrEmpty(name))
            {
                ShowFieldError(lblNameError, "Full name is required.");
                hasError = true;
            }
            else if (name.Length < 2)
            {
                ShowFieldError(lblNameError, "Full name must be at least 2 characters.");
                hasError = true;
            }
            else if (!Regex.IsMatch(name, @"^[a-zA-Z\s]+$"))
            {
                ShowFieldError(lblNameError, "Full name can only contain letters and spaces.");
                hasError = true;
            }

            // ── EMAIL ──────────────────────────────────────────────
            if (string.IsNullOrEmpty(email))
            {
                ShowFieldError(lblEmailError, "Email is required.");
                hasError = true;
            }
            else if (!Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                ShowFieldError(lblEmailError, "Please enter a valid email (e.g. user@email.com).");
                hasError = true;
            }

            // ── USERNAME ───────────────────────────────────────────
            if (string.IsNullOrEmpty(username))
            {
                ShowFieldError(lblUsernameError, "Username is required.");
                hasError = true;
            }
            else if (username.Length < 3)
            {
                ShowFieldError(lblUsernameError, "Username must be at least 3 characters.");
                hasError = true;
            }
            else if (username.Contains(" "))
            {
                ShowFieldError(lblUsernameError, "Username cannot contain spaces.");
                hasError = true;
            }
            else if (!Regex.IsMatch(username, @"^[a-zA-Z0-9_]+$"))
            {
                ShowFieldError(lblUsernameError, "Username can only contain letters, numbers, and underscores.");
                hasError = true;
            }

            // ── PHONE ──────────────────────────────────────────────
            if (string.IsNullOrEmpty(phone))
            {
                ShowFieldError(lblPhoneError, "Phone number is required.");
                hasError = true;
            }
            else if (!phone.All(char.IsDigit))
            {
                ShowFieldError(lblPhoneError, "Phone number can only contain numbers.");
                hasError = true;
            }
            else if (phone.Length != 11)
            {
                ShowFieldError(lblPhoneError, "Phone number must be exactly 11 digits.");
                hasError = true;
            }
            else if (!phone.StartsWith("09"))
            {
                ShowFieldError(lblPhoneError, "Phone number must start with 09.");
                hasError = true;
            }

            // ── ADDRESS ────────────────────────────────────────────
            if (string.IsNullOrEmpty(address))
            {
                ShowFieldError(lblAddressError, "Address is required.");
                hasError = true;
            }
            else if (address.Length < 10)
            {
                ShowFieldError(lblAddressError, "Please enter a complete address (at least 10 characters).");
                hasError = true;
            }
            else if (Regex.IsMatch(address, @"[;'\-\-]"))
            {
                ShowFieldError(lblAddressError, "Address contains invalid characters.");
                hasError = true;
            }

            // ── PASSWORD ───────────────────────────────────────────
            if (string.IsNullOrEmpty(password))
            {
                ShowFieldError(lblPasswordError, "Password is required.");
                hasError = true;
            }
            else if (password.Length < 8)
            {
                ShowFieldError(lblPasswordError, "Password must be at least 8 characters.");
                hasError = true;
            }
            else if (!password.Any(char.IsLetter))
            {
                ShowFieldError(lblPasswordError, "Password must contain at least one letter.");
                hasError = true;
            }
            else if (!password.Any(char.IsDigit))
            {
                ShowFieldError(lblPasswordError, "Password must contain at least one number.");
                hasError = true;
            }

            // ── CONFIRM PASSWORD ───────────────────────────────────
            if (string.IsNullOrEmpty(confirmPassword))
            {
                ShowFieldError(lblConfirmPasswordError, "Please confirm your password.");
                hasError = true;
            }
            else if (password != confirmPassword)
            {
                ShowFieldError(lblConfirmPasswordError, "Passwords do not match.");
                hasError = true;
            }

            // Stop here if any field has an error
            if (hasError) return;

            // ── DATABASE CHECKS + INSERT ───────────────────────────
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Check username duplicate
                    string checkUsernameQuery = "SELECT COUNT(*) FROM USERS WHERE UserName = @Username";
                    using (SqlCommand cmd = new SqlCommand(checkUsernameQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Username", username);
                        if ((int)cmd.ExecuteScalar() > 0)
                        {
                            ShowFieldError(lblUsernameError, "Username already taken. Please choose another.");
                            return;
                        }
                    }

                    // Check email duplicate
                    string checkEmailQuery = "SELECT COUNT(*) FROM USERS WHERE Email = @Email";
                    using (SqlCommand cmd = new SqlCommand(checkEmailQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);
                        if ((int)cmd.ExecuteScalar() > 0)
                        {
                            ShowFieldError(lblEmailError, "Email already registered. Please use a different one.");
                            return;
                        }
                    }

                    // Check phone duplicate
                    string checkPhoneQuery = "SELECT COUNT(*) FROM USERS WHERE PhoneNumber = @Phone";
                    using (SqlCommand cmd = new SqlCommand(checkPhoneQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Phone", phone);
                        if ((int)cmd.ExecuteScalar() > 0)
                        {
                            ShowFieldError(lblPhoneError, "Phone number already registered.");
                            return;
                        }
                    }

                    // INSERT
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
                        cmd.Parameters.AddWithValue("@Password", password);

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            lblMessage.Text = "✓ Registration successful! Redirecting to login...";
                            lblMessage.CssClass = "success-msg";
                            lblMessage.Visible = true;

                            txtName.Text = "";
                            txtEmail.Text = "";
                            txtUsername.Text = "";
                            txtPhone.Text = "";
                            txtAddress.Text = "";
                            txtPassword.Text = "";
                            txtConfirmPassword.Text = "";

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
                lblMessage.Text = "Database Error: " + ex.Message;
                lblMessage.CssClass = "error-msg";
                lblMessage.Visible = true;

                if (ex.InnerException != null)
                    lblMessage.Text += "<br/>Inner Error: " + ex.InnerException.Message;
            }
        }

        // ── HELPERS ────────────────────────────────────────────────
        private void ShowFieldError(Label lbl, string message)
        {
            lbl.Text = "⚠ " + message;
            lbl.Visible = true;
        }

        private void ClearAllErrors()
        {
            lblNameError.Visible = false;
            lblEmailError.Visible = false;
            lblUsernameError.Visible = false;
            lblPhoneError.Visible = false;
            lblAddressError.Visible = false;
            lblPasswordError.Visible = false;
            lblConfirmPasswordError.Visible = false;
            lblMessage.Visible = false;
        }

        protected void lnkLogin_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Login.aspx");
        }
    }
}