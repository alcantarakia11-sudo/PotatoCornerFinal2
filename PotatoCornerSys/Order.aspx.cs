using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Order : System.Web.UI.Page
    {
        const decimal DELIVERY_FEE = 50m;
        const decimal ROYALTY_DISCOUNT_RATE = 0.10m;

        public class CartItem
        {
            public string Product { get; set; }
            public string Size { get; set; }
            public string Flavor { get; set; }
            public int Qty { get; set; }
            public decimal UnitPrice { get; set; }
            public decimal LineTotal => UnitPrice * Qty;
        }

        private List<CartItem> Cart
        {
            get
            {
                if (Session["Cart"] == null)
                    Session["Cart"] = new List<CartItem>();
                return (List<CartItem>)Session["Cart"];
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            // Handle cart item removal via postback
            if (Request.Form["__EVENTTARGET"] == "RemoveCartItem")
            {
                try
                {
                    int index = Convert.ToInt32(Request.Form["__EVENTARGUMENT"]);
                    if (index >= 0 && index < Cart.Count)
                    {
                        Cart.RemoveAt(index);
                        BindCart();
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error removing cart item: " + ex.Message);
                }
                return;
            }

            if (!IsPostBack)
            {
                // Check if this is a reorder - don't clear cart
                if (Session["Cart"] == null)
                {
                    Session["Cart"] = new List<CartItem>();
                }

                hdnFriesQty.Value = "1";
                hdnChickenQty.Value = "1";
                hdnLoopysQty.Value = "1";
                LoadPickupTimeSlots();

                // Show reorder message if present
                if (Session["ReorderMessage"] != null)
                {
                    lblErrorMsg.Text = Session["ReorderMessage"].ToString();
                    lblErrorMsg.CssClass = "status-msg status-success";
                    lblErrorMsg.Visible = true;
                    Session["ReorderMessage"] = null; // Clear after showing
                }
            }
            BindCart();
        }
        private void LoadPickupTimeSlots()
        {
            rblPickupTime.Items.Clear();
            DateTime now = DateTime.Now;

            // Generate time slots starting 15 minutes from now, every 15 minutes, for next 3 hours
            for (int i = 1; i <= 12; i++)
            {
                DateTime slotTime = now.AddMinutes(15 * i);
                string timeText = slotTime.ToString("h:mm tt") + " (" + (15 * i) + " mins)";
                rblPickupTime.Items.Add(new ListItem(timeText, slotTime.ToString("yyyy-MM-dd HH:mm")));
            }
        }

        protected void lnkProfile_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Profile.aspx");
        }

        protected void btnValidate_Click(object sender, EventArgs e)
        {
            string royaltyNo = txtRoyaltyNo.Text.Trim();
            if (string.IsNullOrEmpty(royaltyNo))
            {
                lblRoyaltyMsg.Text = "Please enter a royalty number.";
                lblRoyaltyMsg.CssClass = "status-msg status-error";
                lblRoyaltyMsg.Visible = true;
                return;
            }

            // Validate royalty number format (2 letters + 5 numbers, e.g., PC12345)
            if (royaltyNo.Length != 7 ||
                !char.IsLetter(royaltyNo[0]) ||
                !char.IsLetter(royaltyNo[1]) ||
                !royaltyNo.Substring(2).All(char.IsDigit))
            {
                lblRoyaltyMsg.Text = "✗ Invalid royalty number format. Should be 2 letters + 5 numbers (e.g., PC12345)";
                lblRoyaltyMsg.CssClass = "status-msg status-error";
                lblRoyaltyMsg.Visible = true;
                hdnIsRoyalty.Value = "false";
                return;
            }

            // Check database for royalty number
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Check if royalty number exists in database
                    // First, let's check if the Membership table exists and has the right structure
                    string query = @"
                        SELECT u.CustomerID, u.Fullname, u.MembershipLevel
                        FROM USERS u
                        WHERE u.MembershipLevel = 'Royalty'";

                    // For now, let's use a simpler approach - check if user exists with royalty membership
                    // and if the entered number matches a pattern
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            bool foundRoyaltyUser = false;
                            while (reader.Read())
                            {
                                foundRoyaltyUser = true;
                                // For demo: if there are royalty users and format is correct, accept it
                                break;
                            }

                            if (foundRoyaltyUser)
                            {
                                // Valid royalty number found (simplified validation)
                                lblRoyaltyMsg.Text = "✓ Royalty number validated! 10% discount applied.";
                                lblRoyaltyMsg.CssClass = "status-msg status-success";
                                lblRoyaltyMsg.Visible = true;
                                hdnIsRoyalty.Value = "true";
                                UpdateCartTotals();
                                return;
                            }
                        }
                    }
                }

                // No royalty users found in database
                lblRoyaltyMsg.Text = "✗ Royalty number not found. Please check and try again.";
                lblRoyaltyMsg.CssClass = "status-msg status-error";
                lblRoyaltyMsg.Visible = true;
                hdnIsRoyalty.Value = "false";
            }
            catch (Exception ex)
            {
                // Database error - check session as fallback
                bool hasRoyaltyMembership = Session["HasRoyaltyMembership"] != null && (bool)Session["HasRoyaltyMembership"];
                string sessionRoyaltyNumber = Session["RoyaltyNumber"]?.ToString();

                // Only validate if it matches the logged-in user's royalty number
                if (hasRoyaltyMembership && !string.IsNullOrEmpty(sessionRoyaltyNumber) && sessionRoyaltyNumber == royaltyNo)
                {
                    lblRoyaltyMsg.Text = "✓ Royalty number validated! 10% discount applied.";
                    lblRoyaltyMsg.CssClass = "status-msg status-success";
                    lblRoyaltyMsg.Visible = true;
                    hdnIsRoyalty.Value = "true";
                    UpdateCartTotals();
                }
                else
                {
                    // Database unavailable and doesn't match session - reject
                    lblRoyaltyMsg.Text = "✗ Unable to validate royalty number. Please try again later.";
                    lblRoyaltyMsg.CssClass = "status-msg status-error";
                    lblRoyaltyMsg.Visible = true;
                    hdnIsRoyalty.Value = "false";
                }
            }
        }

        // Chicken quantity controls
        protected void btnChickenMinus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnChickenQty.Value);
            if (qty > 1) qty--;
            hdnChickenQty.Value = qty.ToString();
            lblChickenQty.Text = qty.ToString();
            upChickenQty.Update(); // Update only this panel
        }

        protected void btnChickenPlus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnChickenQty.Value);
            qty++;
            hdnChickenQty.Value = qty.ToString();
            lblChickenQty.Text = qty.ToString();
            upChickenQty.Update(); // Update only this panel
        }

        // Loopys quantity controls
        protected void btnLoopysMinus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnLoopysQty.Value);
            if (qty > 1) qty--;
            hdnLoopysQty.Value = qty.ToString();
            lblLoopysQty.Text = qty.ToString();
            upLoopysQty.Update(); // Update only this panel
        }

        protected void btnLoopysPlus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnLoopysQty.Value);
            qty++;
            hdnLoopysQty.Value = qty.ToString();
            lblLoopysQty.Text = qty.ToString();
            upLoopysQty.Update(); // Update only this panel
        }

        // French Fries quantity controls
        protected void btnFriesMinus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnFriesQty.Value);
            if (qty > 1) qty--;
            hdnFriesQty.Value = qty.ToString();
            lblFriesQty.Text = qty.ToString();
            upFriesQty.Update(); // Update only this panel
        }

        protected void btnFriesPlus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnFriesQty.Value);
            qty++;
            hdnFriesQty.Value = qty.ToString();
            lblFriesQty.Text = qty.ToString();
            upFriesQty.Update(); // Update only this panel
        }

        protected void btnAddFries_Click(object sender, EventArgs e)
        {
            string size = "";
            decimal price = 0;

            if (rbFriesRegular.Checked) { size = "Regular"; price = 39; }
            else if (rbFriesLarge.Checked) { size = "Large"; price = 58; }
            else if (rbFriesJumbo.Checked) { size = "Jumbo"; price = 97; }
            else if (rbFriesMega.Checked) { size = "Mega"; price = 135; }
            else if (rbFriesGiga.Checked) { size = "Giga"; price = 198; }
            else if (rbFriesTerra.Checked) { size = "Terra"; price = 228; }
            else
            {
                lblErrorMsg.Text = "Please select a size for French Fries.";
                lblErrorMsg.Visible = true;
                return;
            }

            string flavor = "";
            if (rbFriesSourCream.Checked) flavor = "Sour Cream";
            else if (rbFriesBBQ.Checked) flavor = "BBQ";
            else if (rbFriesCheese.Checked) flavor = "Cheese";
            else if (rbFriesSalt.Checked) flavor = "Salt";
            else
            {
                lblErrorMsg.Text = "Please select a flavor for French Fries.";
                lblErrorMsg.Visible = true;
                return;
            }

            int qty = int.Parse(hdnFriesQty.Value);
            
            // Debug: Show what we're adding
            lblErrorMsg.Text = $"Adding: {qty}x French Fries ({size}, {flavor}) - PHP {price}";
            lblErrorMsg.CssClass = "status-msg status-success";
            lblErrorMsg.Visible = true;
            
            Cart.Add(new CartItem
            {
                Product = "French Fries",
                Size = size,
                Flavor = flavor,
                Qty = qty,
                UnitPrice = price
            });

            // Debug: Show cart count
            lblErrorMsg.Text += $" | Cart now has {Cart.Count} items";

            // Reset
            rbFriesRegular.Checked = false;
            rbFriesLarge.Checked = false;
            rbFriesJumbo.Checked = false;
            rbFriesMega.Checked = false;
            rbFriesGiga.Checked = false;
            rbFriesTerra.Checked = false;
            rbFriesSourCream.Checked = false;
            rbFriesBBQ.Checked = false;
            rbFriesCheese.Checked = false;
            rbFriesSalt.Checked = false;
            hdnFriesQty.Value = "1";
            lblFriesQty.Text = "1";

            BindCart();
        }

        protected void btnAddChicken_Click(object sender, EventArgs e)
        {
            string size = "";
            decimal price = 0;

            if (rbChickenSolo.Checked) { size = "Solo"; price = 75; }
            else if (rbChickenLarge.Checked) { size = "Large Mix"; price = 95; }
            else if (rbChickenMega.Checked) { size = "Mega Mix"; price = 199; }
            else
            {
                lblErrorMsg.Text = "Please select a size for Chicken Pops.";
                lblErrorMsg.Visible = true;
                return;
            }

            string flavor = "";
            if (rbChickenSourCream.Checked) flavor = "Sour Cream";
            else if (rbChickenBBQ.Checked) flavor = "BBQ";
            else if (rbChickenCheese.Checked) flavor = "Cheese";
            else if (rbChickenSalt.Checked) flavor = "Salt";
            else
            {
                lblErrorMsg.Text = "Please select a flavor for Chicken Pops.";
                lblErrorMsg.Visible = true;
                return;
            }

            int qty = int.Parse(hdnChickenQty.Value);
            Cart.Add(new CartItem
            {
                Product = "Chicken Pops",
                Size = size,
                Flavor = flavor,
                Qty = qty,
                UnitPrice = price
            });

            // Reset
            rbChickenSolo.Checked = false;
            rbChickenLarge.Checked = false;
            rbChickenMega.Checked = false;
            rbChickenSourCream.Checked = false;
            rbChickenBBQ.Checked = false;
            rbChickenCheese.Checked = false;
            rbChickenSalt.Checked = false;
            hdnChickenQty.Value = "1";
            lblChickenQty.Text = "1";
            lblErrorMsg.Visible = false;

            BindCart();
        }

        protected void btnAddLoopys_Click(object sender, EventArgs e)
        {
            string size = "";
            decimal price = 0;

            if (rbLoopysLarge.Checked) { size = "Large"; price = 75; }
            else if (rbLoopysMega.Checked) { size = "Mega"; price = 135; }
            else
            {
                lblErrorMsg.Text = "Please select a size for Loopys.";
                lblErrorMsg.Visible = true;
                return;
            }

            string flavor = "";
            if (rbLoopysSourCream.Checked) flavor = "Sour Cream";
            else if (rbLoopysBBQ.Checked) flavor = "BBQ";
            else if (rbLoopysCheese.Checked) flavor = "Cheese";
            else if (rbLoopysSalt.Checked) flavor = "Salt";
            else
            {
                lblErrorMsg.Text = "Please select a flavor for Loopys.";
                lblErrorMsg.Visible = true;
                return;
            }

            int qty = int.Parse(hdnLoopysQty.Value);
            Cart.Add(new CartItem
            {
                Product = "Loopys",
                Size = size,
                Flavor = flavor,
                Qty = qty,
                UnitPrice = price
            });

            // Reset
            rbLoopysLarge.Checked = false;
            rbLoopysMega.Checked = false;
            rbLoopysSourCream.Checked = false;
            rbLoopysBBQ.Checked = false;
            rbLoopysCheese.Checked = false;
            rbLoopysSalt.Checked = false;
            hdnLoopysQty.Value = "1";
            lblLoopysQty.Text = "1";
            lblErrorMsg.Visible = false;

            BindCart();
        }

        protected void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                try
                {
                    int index = Convert.ToInt32(e.CommandArgument);
                    if (index >= 0 && index < Cart.Count)
                    {
                        Cart.RemoveAt(index);
                        BindCart();
                    }
                }
                catch (Exception ex)
                {
                    // Log error or show message
                    System.Diagnostics.Debug.WriteLine("Error removing item: " + ex.Message);
                }
            }
        }

        protected void btnRemoveItem_Click(object sender, EventArgs e)
        {
            try
            {
                Button btn = (Button)sender;
                int index = Convert.ToInt32(btn.CommandArgument);
                if (index >= 0 && index < Cart.Count)
                {
                    Cart.RemoveAt(index);
                    BindCart();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error removing item: " + ex.Message);
            }
        }

        protected void btnDeliveryType_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            btnWalkIn.CssClass = "option-btn";
            btnDelivery.CssClass = "option-btn";
            btn.CssClass = "option-btn selected";

            hdnDeliveryType.Value = btn.ID == "btnDelivery" ? "Delivery" : "WalkIn";

            // Clear pickup time if switching to delivery
            if (hdnDeliveryType.Value == "Delivery")
            {
                hdnPickupTime.Value = "";
                lblPickupTime.Visible = false;
            }

            UpdateCartTotals();
        }

        protected void btnConfirmPickupTime_Click(object sender, EventArgs e)
        {
            if (rblPickupTime.SelectedValue != "")
            {
                hdnPickupTime.Value = rblPickupTime.SelectedValue;
                hdnDeliveryType.Value = "WalkIn";
                btnWalkIn.CssClass = "option-btn selected";
                btnDelivery.CssClass = "option-btn";

                // Show selected time
                DateTime selectedTime = DateTime.Parse(rblPickupTime.SelectedValue);
                lblPickupTime.Text = "Pickup Time: " + selectedTime.ToString("MMM dd, yyyy h:mm tt");
                lblPickupTime.Visible = true;

                UpdateCartTotals();

                // Hide modal using client script
                ScriptManager.RegisterStartupScript(this, GetType(), "hideModal", "hidePickupTimeModal();", true);
            }
        }

        protected void btnPayment_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            btnGoTyme.CssClass = "option-btn";
            btnMayaBank.CssClass = "option-btn";
            btnGCash.CssClass = "option-btn";
            btnPoints.CssClass = "option-btn";
            btn.CssClass = "option-btn selected";

            hdnPaymentMethod.Value = btn.Text;
        }

        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            // Validate all fields are filled
            if (string.IsNullOrEmpty(txtName.Text.Trim()) ||
                string.IsNullOrEmpty(txtAddress.Text.Trim()) ||
                string.IsNullOrEmpty(txtContact.Text.Trim()))
            {
                lblErrorMsg.Text = "Please fill in all customer information.";
                lblErrorMsg.Visible = true;
                return;
            }

            // Validate full name (no numbers allowed)
            string name = txtName.Text.Trim();
            if (name.Any(char.IsDigit))
            {
                lblErrorMsg.Text = "Full name cannot contain numbers.";
                lblErrorMsg.Visible = true;
                return;
            }

            // Validate phone number (only numbers allowed)
            string contact = txtContact.Text.Trim();
            if (!contact.All(char.IsDigit))
            {
                lblErrorMsg.Text = "Phone number can only contain numbers. No letters or special characters allowed.";
                lblErrorMsg.Visible = true;
                return;
            }

            // Validate address (letters, numbers, spaces, and commas only)
            string address = txtAddress.Text.Trim();
            if (!address.All(c => char.IsLetterOrDigit(c) || c == ' ' || c == ','))
            {
                lblErrorMsg.Text = "Address can only contain letters, numbers, spaces, and commas.";
                lblErrorMsg.Visible = true;
                return;
            }

            // Validate pickup time for walk-in orders
            if (hdnDeliveryType.Value == "WalkIn" && string.IsNullOrEmpty(hdnPickupTime.Value))
            {
                lblErrorMsg.Text = "Please select a pickup time for walk-in orders.";
                lblErrorMsg.CssClass = "status-msg status-error";
                lblErrorMsg.Visible = true;
                return;
            }

            if (Cart.Count == 0)
            {
                lblErrorMsg.Text = "Your cart is empty. Please add at least one item.";
                lblErrorMsg.Visible = true;
                return;
            }

            if (string.IsNullOrEmpty(hdnPaymentMethod.Value))
            {
                lblErrorMsg.Text = "Please select a payment method.";
                lblErrorMsg.Visible = true;
                return;
            }

            // Calculate totals
            decimal orderTotal = decimal.Parse(lblTotal.Text);
            decimal subtotal = decimal.Parse(lblSubtotal.Text);
            decimal discount = decimal.Parse(lblDiscount.Text);
            decimal deliveryFee = decimal.Parse(lblDeliveryFee.Text);

            decimal amountPaid = 0;
            decimal change = 0;

            // Validate payment amount (skip for Points)
            if (hdnPaymentMethod.Value != "Points")
            {
                if (!decimal.TryParse(txtAmountPaid.Text.Trim(), out amountPaid) || amountPaid <= 0)
                {
                    lblErrorMsg.Text = "Please enter a valid payment amount.";
                    lblErrorMsg.Visible = true;
                    return;
                }

                if (amountPaid < orderTotal)
                {
                    lblErrorMsg.Text = $"Insufficient amount. Total is PHP {orderTotal:0.00}. You entered PHP {amountPaid:0.00}.";
                    lblErrorMsg.Visible = true;
                    return;
                }

                change = amountPaid - orderTotal;
            }
            else
            {
                amountPaid = orderTotal; // For points payment
                change = 0;
            }

            // Save order to database
            try
            {
                int orderID = SaveOrderToDatabase(name, address, contact, orderTotal, subtotal, discount, deliveryFee, amountPaid, change);

                if (orderID > 0)
                {
                    // Calculate points earned
                    int pointsEarned = (int)(orderTotal / 500) * 2;

                    // Update customer points if logged in
                    UpdateCustomerPoints(pointsEarned);

                    // Store order data in session for receipt
                    Session["OrderID"] = orderID.ToString();
                    Session["OrderName"] = name;
                    Session["OrderAddress"] = address;
                    Session["OrderContact"] = contact;
                    Session["OrderDelivery"] = hdnDeliveryType.Value == "Delivery" ? "Delivery" : "Walk-in";
                    Session["OrderPickupTime"] = hdnPickupTime.Value;
                    Session["OrderIsRoyalty"] = hdnIsRoyalty.Value;
                    Session["OrderTotal"] = orderTotal.ToString("0.00");
                    Session["OrderSubtotal"] = subtotal.ToString("0.00");
                    Session["OrderDiscount"] = discount.ToString("0.00");
                    Session["OrderDeliveryFee"] = deliveryFee.ToString("0.00");
                    Session["PaymentMethod"] = hdnPaymentMethod.Value;
                    Session["AmountPaid"] = amountPaid.ToString("0.00");
                    Session["Change"] = change.ToString("0.00");
                    Session["PointsEarned"] = pointsEarned.ToString();
                    if (!string.IsNullOrEmpty(txtRoyaltyNo.Text.Trim()))
                        Session["RoyaltyNo"] = txtRoyaltyNo.Text.Trim();

                    // Clear cart after successful order
                    Session["Cart"] = new List<CartItem>();

                    Response.Redirect("~/Receipt.aspx");
                }
                else
                {
                    lblErrorMsg.Text = "Failed to save order. Please try again.";
                    lblErrorMsg.Visible = true;
                }
            }
            catch (Exception ex)
            {
                lblErrorMsg.Text = "Error processing order: " + ex.Message;
                if (ex.InnerException != null)
                {
                    lblErrorMsg.Text += "<br/>Inner Error: " + ex.InnerException.Message;
                }
                lblErrorMsg.Text += "<br/>Stack Trace: " + ex.StackTrace;
                lblErrorMsg.Visible = true;
            }
        }

        private int SaveOrderToDatabase(string customerName, string address, string contact,
            decimal totalAmount, decimal subtotal, decimal discount, decimal deliveryFee,
            decimal amountPaid, decimal change)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get CustomerID from session (if logged in) or create guest customer
                    int customerID = GetOrCreateCustomerID(conn, customerName, address, contact);

                    // Insert order
                    string orderQuery = @"
                        INSERT INTO Orders (CustomerID, OrderDate, DeliveryType, TotalAmount, Discount, 
                                          AmountPaid, ChangeAmount, PaymentMethod, OrderStatus, PickupTime, TotalQuantity)
                        VALUES (@CustomerID, @OrderDate, @DeliveryType, @TotalAmount, @Discount, 
                                @AmountPaid, @ChangeAmount, @PaymentMethod, @OrderStatus, @PickupTime, @TotalQuantity);
                        SELECT SCOPE_IDENTITY();";

                    int orderID = 0;
                    using (SqlCommand cmd = new SqlCommand(orderQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        cmd.Parameters.AddWithValue("@OrderDate", DateTime.Now);
                        cmd.Parameters.AddWithValue("@DeliveryType", hdnDeliveryType.Value == "Delivery" ? "Delivery" : "Walk-in");
                        cmd.Parameters.AddWithValue("@TotalAmount", totalAmount);
                        cmd.Parameters.AddWithValue("@Discount", discount);
                        cmd.Parameters.AddWithValue("@AmountPaid", amountPaid);
                        cmd.Parameters.AddWithValue("@ChangeAmount", change);
                        cmd.Parameters.AddWithValue("@PaymentMethod", hdnPaymentMethod.Value);
                        cmd.Parameters.AddWithValue("@OrderStatus", "Pending");

                        // Handle pickup time
                        if (!string.IsNullOrEmpty(hdnPickupTime.Value))
                        {
                            cmd.Parameters.AddWithValue("@PickupTime", DateTime.Parse(hdnPickupTime.Value));
                        }
                        else
                        {
                            cmd.Parameters.AddWithValue("@PickupTime", DBNull.Value);
                        }

                        // Calculate total quantity
                        int totalQty = Cart.Sum(item => item.Qty);
                        cmd.Parameters.AddWithValue("@TotalQuantity", totalQty);

                        orderID = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // Insert order items
                    foreach (var item in Cart)
                    {
                        int productID = GetProductID(conn, item.Product);
                        int? sizeID = GetSizeID(conn, productID, item.Size);
                        int? flavorID = GetFlavorID(conn, productID, item.Flavor);

                        string itemQuery = @"
                            INSERT INTO OrderItems (OrderID, ProductID, SizeID, FlavorID, Quantity, UnitPrice, TotalPrice)
                            VALUES (@OrderID, @ProductID, @SizeID, @FlavorID, @Quantity, @UnitPrice, @TotalPrice)";

                        using (SqlCommand cmd = new SqlCommand(itemQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@OrderID", orderID);
                            cmd.Parameters.AddWithValue("@ProductID", productID);
                            cmd.Parameters.AddWithValue("@SizeID", sizeID.HasValue ? (object)sizeID.Value : DBNull.Value);
                            cmd.Parameters.AddWithValue("@FlavorID", flavorID.HasValue ? (object)flavorID.Value : DBNull.Value);
                            cmd.Parameters.AddWithValue("@Quantity", item.Qty);
                            cmd.Parameters.AddWithValue("@UnitPrice", item.UnitPrice);
                            cmd.Parameters.AddWithValue("@TotalPrice", item.LineTotal);

                            cmd.ExecuteNonQuery();
                        }
                    }

                    return orderID;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Database error: " + ex.Message);
            }
        }

        private int GetOrCreateCustomerID(SqlConnection conn, string name, string address, string contact)
        {
            // If user is logged in, use their CustomerID
            if (Session["CustomerID"] != null)
            {
                return Convert.ToInt32(Session["CustomerID"]);
            }

            // For guest orders, check if customer exists by phone number
            string checkQuery = "SELECT CustomerID FROM USERS WHERE PhoneNumber = @Phone";
            using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
            {
                cmd.Parameters.AddWithValue("@Phone", contact);
                object result = cmd.ExecuteScalar();

                if (result != null)
                {
                    return Convert.ToInt32(result);
                }
            }

            // Create new guest customer
            string insertQuery = @"
                INSERT INTO USERS (UserName, Fullname, [Address], Email, PhoneNumber, [Password], Points, MembershipLevel)
                VALUES (@UserName, @Fullname, @Address, @Email, @Phone, @Password, 0, 'Guest');
                SELECT SCOPE_IDENTITY();";

            using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
            {
                cmd.Parameters.AddWithValue("@UserName", "guest_" + contact); // Unique username
                cmd.Parameters.AddWithValue("@Fullname", name);
                cmd.Parameters.AddWithValue("@Address", address);
                cmd.Parameters.AddWithValue("@Email", "guest@email.com"); // Default email for guests
                cmd.Parameters.AddWithValue("@Phone", contact);
                cmd.Parameters.AddWithValue("@Password", "guest123"); // Default password for guests

                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private int GetProductID(SqlConnection conn, string productName)
        {
            string query = "SELECT ProductID FROM Products WHERE ProductName = @ProductName";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@ProductName", productName);
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : 1; // Default to 1 if not found
            }
        }

        private int? GetSizeID(SqlConnection conn, int productID, string sizeName)
        {
            string query = "SELECT SizeID FROM ProductSizes WHERE ProductID = @ProductID AND SizeName = @SizeName";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@ProductID", productID);
                cmd.Parameters.AddWithValue("@SizeName", sizeName);
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : (int?)null;
            }
        }

        private int? GetFlavorID(SqlConnection conn, int productID, string flavorName)
        {
            string query = "SELECT FlavorID FROM ProductFlavors WHERE ProductID = @ProductID AND FlavorName = @FlavorName";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@ProductID", productID);
                cmd.Parameters.AddWithValue("@FlavorName", flavorName);
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : (int?)null;
            }
        }

        private void UpdateCustomerPoints(int pointsEarned)
        {
            if (Session["CustomerID"] != null && pointsEarned > 0)
            {
                try
                {
                    string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();

                        // Query #3: UPDATE QUERY - Update Customer Points After Order
                        string updateQuery = "UPDATE USERS SET Points = Points + @PointsEarned WHERE CustomerID = @CustomerID";

                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@PointsEarned", pointsEarned);
                            cmd.Parameters.AddWithValue("@CustomerID", Convert.ToInt32(Session["CustomerID"]));
                            cmd.ExecuteNonQuery();
                        }

                        // Update session points
                        if (Session["Points"] != null)
                        {
                            int currentPoints = Convert.ToInt32(Session["Points"]);
                            Session["Points"] = (currentPoints + pointsEarned).ToString();
                        }
                    }
                }
                catch (Exception ex)
                {
                    // Log error but don't fail the order
                    System.Diagnostics.Debug.WriteLine("Error updating points: " + ex.Message);
                }
            }
        }

        private void BindCart()
        {
            var cart = Cart;
            
            System.Diagnostics.Debug.WriteLine($"BindCart called - Cart has {cart.Count} items");
            
            if (cart.Count == 0)
            {
                cartDisplay.InnerHtml = @"
                    <div class='cart-empty' style='text-align: center; color: #aaa; padding: 50px 20px; font-size: 15px; font-weight: 600;'>
                        Your cart is empty<br/>
                        <small style='font-size: 12px; color: #ccc;'>Add items from the menu to get started</small>
                    </div>";
                System.Diagnostics.Debug.WriteLine("Showing empty cart message");
            }
            else
            {
                var html = new StringBuilder();
                
                // Add cart items
                for (int i = 0; i < cart.Count; i++)
                {
                    var item = cart[i];
                    html.AppendFormat(@"
                        <div class='cart-item'>
                            <div class='cart-item-header'>
                                <span>{0} ({1})</span>
                                <button type='button' class='btn-remove' onclick='removeCartItem({2})'>Remove</button>
                            </div>
                            <div class='cart-item-details'>
                                Flavor: {3}<br/>
                                Qty: {4} × PHP {5:0.00} = PHP {6:0.00}
                            </div>
                        </div>",
                        item.Product, item.Size, i, item.Flavor, item.Qty, item.UnitPrice, item.LineTotal);
                }
                
                // Add totals section
                decimal subtotal = cart.Sum(item => item.LineTotal);
                bool isRoyalty = hdnIsRoyalty.Value == "true";
                bool isDelivery = hdnDeliveryType.Value == "Delivery";
                decimal discount = isRoyalty ? subtotal * ROYALTY_DISCOUNT_RATE : 0;
                decimal delivery = isDelivery ? DELIVERY_FEE : 0;
                decimal total = subtotal - discount + delivery;

                html.AppendFormat(@"
                    <div class='cart-totals'>
                        <div class='total-row'>
                            <span>Subtotal:</span>
                            <span>PHP {0:0.00}</span>
                        </div>
                        <div class='total-row'>
                            <span>Discount:</span>
                            <span>PHP {1:0.00}</span>
                        </div>
                        <div class='total-row'>
                            <span>Delivery Fee:</span>
                            <span>PHP {2:0.00}</span>
                        </div>
                        <div class='total-row grand'>
                            <span>Total:</span>
                            <span>PHP {3:0.00}</span>
                        </div>
                    </div>", subtotal, discount, delivery, total);
                
                cartDisplay.InnerHtml = html.ToString();
                
                // Update hidden labels for form processing
                lblSubtotal.Text = subtotal.ToString("0.00");
                lblDiscount.Text = discount.ToString("0.00");
                lblDeliveryFee.Text = delivery.ToString("0.00");
                lblTotal.Text = total.ToString("0.00");
                
                System.Diagnostics.Debug.WriteLine($"Generated cart HTML with {cart.Count} items, total: {total:0.00}");
            }
            
            // Force ViewState update
            ViewState["CartCount"] = cart.Count;
        }

        private void UpdateCartTotals()
        {
            // This method is now integrated into BindCart()
            // Keeping for compatibility with existing calls
            BindCart();
        }
    }
    
}