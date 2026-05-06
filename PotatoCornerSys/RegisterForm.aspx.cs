using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class RegisterForm : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (IsAlreadyRoyaltyMember())
                {
                    string script = @"
                        document.addEventListener('DOMContentLoaded', function() {
                            showAlreadyMemberModal();
                        });
                    ";
                    ClientScript.RegisterStartupScript(this.GetType(), "AlreadyMember", script, true);
                    return;
                }
            }
        }

        private bool IsAlreadyRoyaltyMember()
        {
            try
            {
                if (Session["HasRoyaltyMembership"] != null && (bool)Session["HasRoyaltyMembership"])
                    return true;

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);

                    if (customerID == 0) return false;

                    string query = @"
                        SELECT COUNT(*) 
                        FROM Membership m
                        INNER JOIN USERS u ON m.CustomerID = u.CustomerID
                        WHERE m.CustomerID = @CustomerID AND u.MembershipLevel = 'Royalty'";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        int count = (int)cmd.ExecuteScalar();
                        return count > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error checking membership: " + ex.Message);
                return false;
            }
        }

        protected void btnPaymentMethod_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            btnGoTyme.CssClass = "payment-btn";
            btnMayaBank.CssClass = "payment-btn";
            btnGCash.CssClass = "payment-btn";
            btnPoints.CssClass = "payment-btn";
            btn.CssClass = "payment-btn selected";

            hdnPaymentMethod.Value = btn.Text;
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            try
            {
                // Basic validation
                if (string.IsNullOrWhiteSpace(txtFullName.Text) ||
                    string.IsNullOrWhiteSpace(txtEmail.Text) ||
                    string.IsNullOrWhiteSpace(txtContact.Text))
                {
                    ShowMessage("Please fill in all required fields.", false);
                    return;
                }

                if (!fileUploadPicture.HasFile)
                {
                    ShowMessage("Please upload your profile picture.", false);
                    return;
                }

                // Validate image file type
                string fileExtension = Path.GetExtension(fileUploadPicture.FileName).ToLower();
                string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };
                if (!allowedExtensions.Contains(fileExtension))
                {
                    ShowMessage("Please upload a valid image file (JPG, JPEG, PNG, GIF).", false);
                    return;
                }

                if (string.IsNullOrEmpty(hdnPaymentMethod.Value))
                {
                    ShowMessage("Please select a payment method.", false);
                    return;
                }

                decimal amountPaid;
               if (!decimal.TryParse(txtAmountPaid.Text.Trim(), out amountPaid) || amountPaid != 100)
{
    ShowMessage("Amount paid must be exactly PHP 100.", false);
    return;
}
                // Generate royalty number
                Random random = new Random();
                string royaltyNumber = "PC" + random.Next(10000, 99999).ToString();

                // ✅ Read image as bytes (for DB storage)
                byte[] imageBytes = fileUploadPicture.FileBytes;
                string fileName = royaltyNumber + fileExtension;

                // Also save to Uploads folder (optional but good for backup)
                string uploadsFolder = Server.MapPath("~/Uploads/");
                if (!Directory.Exists(uploadsFolder))
                    Directory.CreateDirectory(uploadsFolder);

                string filePath = Path.Combine(uploadsFolder, fileName);
                fileUploadPicture.SaveAs(filePath);

                // Database operation
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);

                    if (customerID == 0)
                    {
                        // Create guest customer
                        string insertGuestQuery = @"
                            INSERT INTO USERS (UserName, Fullname, [Address], Email, PhoneNumber, [Password], Points, MembershipLevel)
                            VALUES (@UserName, @Fullname, @Address, @Email, @Phone, @Password, 0, 'Guest');
                            SELECT SCOPE_IDENTITY();";

                        using (SqlCommand guestCmd = new SqlCommand(insertGuestQuery, conn))
                        {
                            guestCmd.Parameters.AddWithValue("@UserName", "member_" + txtContact.Text.Trim());
                            guestCmd.Parameters.AddWithValue("@Fullname", txtFullName.Text.Trim());
                            guestCmd.Parameters.AddWithValue("@Address", "Not provided");
                            guestCmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                            guestCmd.Parameters.AddWithValue("@Phone", txtContact.Text.Trim());
                            guestCmd.Parameters.AddWithValue("@Password", "member123");

                            customerID = Convert.ToInt32(guestCmd.ExecuteScalar());
                            Session["CustomerID"] = customerID.ToString();
                        }
                    }

                    // ✅ INSERT including ProfilePicture (binary) and PictureFileName
                    string insertQuery = @"
                        INSERT INTO Membership (CustomerID, MembershipNumber, Points, RegistrationDate, ProfilePicture, PictureFileName)
                        VALUES (@CustomerID, @MembershipNumber, @Points, @RegistrationDate, @ProfilePicture, @PictureFileName)";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        cmd.Parameters.AddWithValue("@MembershipNumber", royaltyNumber);
                        cmd.Parameters.AddWithValue("@Points", 0);
                        cmd.Parameters.AddWithValue("@RegistrationDate", DateTime.Now);
                        cmd.Parameters.Add("@ProfilePicture", System.Data.SqlDbType.VarBinary).Value = imageBytes; // ✅ Binary image
                        cmd.Parameters.AddWithValue("@PictureFileName", "PotatoCornerSys/Uploads/" + fileName);// ✅ File name

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            // Update user to Royalty
                            string updateQuery = "UPDATE USERS SET MembershipLevel = 'Royalty' WHERE CustomerID = @CustomerID";
                            using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn))
                            {
                                updateCmd.Parameters.AddWithValue("@CustomerID", customerID);
                                updateCmd.ExecuteNonQuery();
                            }

                            // Store session data
                            Session["RoyaltyNumber"] = royaltyNumber;
                            Session["MemberFullName"] = txtFullName.Text.Trim();
                            Session["MemberEmail"] = txtEmail.Text.Trim();
                            Session["MemberContact"] = txtContact.Text.Trim();
                            Session["MemberPicture"] = "~/Uploads/" + fileName;
                            Session["RegistrationDate"] = DateTime.Now.ToString("MMMM dd, yyyy");
                            Session["RegistrationFee"] = "100.00";
                            Session["PaymentMethod"] = hdnPaymentMethod.Value;
                            Session["AmountPaid"] = amountPaid.ToString("0.00");
                            Session["ChangeAmount"] = (amountPaid - 100).ToString("0.00");
                            Session["HasRoyaltyMembership"] = true;
                            Session["MembershipLevel"] = "Royalty";

                            ShowMessage("Registration successful! Your membership number is: " + royaltyNumber, true);
                            Response.AddHeader("REFRESH", "2;URL=MembershipReceipt.aspx");
                        }
                        else
                        {
                            ShowMessage("Registration failed. Please try again.", false);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Registration error: " + ex.Message, false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = isSuccess ? "success-msg" : "error-msg";
            lblMessage.Visible = true;
        }
    }
}
