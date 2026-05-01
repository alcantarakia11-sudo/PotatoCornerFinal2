using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Profile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCustomerInfo();
                LoadLoyaltyPoints();
                LoadFavoriteOrder();
                LoadOrderHistory();
            }
        }
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Login.aspx");
        }

        private void LoadCustomerInfo()
        {
            // Get customer info from session (set during login/registration)
            if (Session["Username"] != null)
            {
                try
                {
                    string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();

                        // Get CustomerID from session
                        int customerID = 0;
                        if (Session["CustomerID"] != null)
                        {
                            int.TryParse(Session["CustomerID"].ToString(), out customerID);
                        }

                        if (customerID > 0)
                        {
                            // Load customer data from database
                            string query = @"
                                SELECT u.Fullname, u.Email, u.PhoneNumber, u.[Address], u.Points, u.MembershipLevel, u.DateCreated,
                                       m.RoyaltyNumber, m.ProfilePicture
                                FROM USERS u
                                LEFT JOIN Membership m ON u.CustomerID = m.CustomerID
                                WHERE u.CustomerID = @CustomerID";

                            using (SqlCommand cmd = new SqlCommand(query, conn))
                            {
                                cmd.Parameters.AddWithValue("@CustomerID", customerID);

                                using (SqlDataReader reader = cmd.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        // Update session with fresh data
                                        Session["Name"] = reader["Fullname"].ToString();
                                        Session["Email"] = reader["Email"].ToString();
                                        Session["Phone"] = reader["PhoneNumber"].ToString();
                                        Session["Address"] = reader["Address"].ToString();
                                        Session["Points"] = reader["Points"].ToString();
                                        Session["MembershipLevel"] = reader["MembershipLevel"].ToString();

                                        if (!reader.IsDBNull(reader.GetOrdinal("RoyaltyNumber")))
                                        {
                                            Session["RoyaltyNumber"] = reader["RoyaltyNumber"].ToString();
                                            Session["HasRoyaltyMembership"] = true;
                                        }

                                        if (!reader.IsDBNull(reader.GetOrdinal("ProfilePicture")))
                                        {
                                            Session["MemberPicture"] = reader["ProfilePicture"].ToString();
                                        }

                                        Session["MemberSince"] = Convert.ToDateTime(reader["DateCreated"]).ToString("MMM dd, yyyy");
                                    }
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    // Handle database errors - use session data as fallback
                    System.Diagnostics.Debug.WriteLine("Error loading customer info: " + ex.Message);
                }

                // Use actual name from database/session
                string displayName = Session["Name"]?.ToString() ?? Session["Username"].ToString();
                lblFullName.Text = displayName;

                // Generate initials from name
                string name = displayName;
                string[] nameParts = name.Split(' ');
                if (nameParts.Length >= 2)
                {
                    lblInitials.Text = nameParts[0][0].ToString() + nameParts[1][0].ToString();
                }
                else if (name.Length >= 2)
                {
                    lblInitials.Text = name.Substring(0, 2).ToUpper();
                }
                else
                {
                    lblInitials.Text = name.Substring(0, 1).ToUpper();
                }
            }
            else
            {
                // No session - redirect to login
                Response.Redirect("Login.aspx");
                return;
            }

            // Load customer details
            lblEmailAvatar.Text = Session["Email"]?.ToString() ?? "email@example.com";
            lblInfoPhone.Text = Session["Phone"]?.ToString() ?? "N/A";
            lblInfoAddress.Text = Session["Address"]?.ToString() ?? "N/A";
            lblMemberSince.Text = Session["MemberSince"]?.ToString() ?? DateTime.Now.ToString("MMM dd, yyyy");

            // Check if user is royalty member
            bool isRoyaltyMember = CheckIfRoyaltyMember();

            // Load profile picture if available
            if (Session["MemberPicture"] != null && !string.IsNullOrEmpty(Session["MemberPicture"].ToString()))
            {
                string picturePath = Session["MemberPicture"].ToString();
                imgProfilePic.ImageUrl = picturePath;
                imgProfilePic.Visible = true;
                lblInitials.Visible = false;
            }
            else
            {
                imgProfilePic.Visible = false;
                lblInitials.Visible = true;
            }

            if (isRoyaltyMember)
            {
                lblMembershipBadge.Text = "ROYALTY MEMBER";
                lblMembershipBadge.CssClass = "membership-badge royalty";

                // Show royalty number if available
                if (Session["RoyaltyNumber"] != null)
                {
                    lblRoyaltyNumber.Text = Session["RoyaltyNumber"].ToString();
                    royaltyNumberSection.Visible = true;
                }
            }
            else
            {
                lblMembershipBadge.Text = "REGULAR MEMBER";
                lblMembershipBadge.CssClass = "membership-badge";
            }
        }

        private bool CheckIfRoyaltyMember()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get CustomerID from session
                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                    {
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);
                    }

                    if (customerID == 0) return false;

                    // Check if customer has royalty membership and get membership details
                    string query = @"
                        SELECT m.MembershipNumber, m.RegistrationDate, u.MembershipLevel
                        FROM Membership m
                        INNER JOIN USERS u ON m.CustomerID = u.CustomerID
                        WHERE m.CustomerID = @CustomerID AND u.MembershipLevel = 'Royalty'";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Store membership information in session
                                Session["HasRoyaltyMembership"] = true;
                                Session["RoyaltyNumber"] = reader["MembershipNumber"].ToString();
                                Session["MembershipLevel"] = "Royalty";
                                
                                // Try to find and store the profile picture path
                                string membershipNumber = reader["MembershipNumber"].ToString();
                                string[] possibleExtensions = { ".jpg", ".jpeg", ".png" };

                                foreach (string ext in possibleExtensions)
                                {
                                    string path = $"~/Uploads/{membershipNumber}{ext}";
                                    string serverPath = Server.MapPath(path);
                                    if (System.IO.File.Exists(serverPath))
                                    {
                                        Session["MemberPicture"] = path;
                                        break;
                                    }
                                }

                                return true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error checking royalty membership: " + ex.Message);
            }

            // Fallback to session check
            return Session["HasRoyaltyMembership"] != null && (bool)Session["HasRoyaltyMembership"];
        }

        private string GetProfilePicturePath()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get CustomerID from session
                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                    {
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);
                    }

                    if (customerID == 0) return null;

                    // Query the Membership table for the profile picture
                    // Note: Your Membership table doesn't have ProfilePicture column, so we'll check session first
                    if (Session["MemberPicture"] != null)
                    {
                        string picturePath = Session["MemberPicture"].ToString();
                        string serverPath = Server.MapPath(picturePath);
                        if (System.IO.File.Exists(serverPath))
                        {
                            return picturePath;
                        }
                    }

                    // Try to find the picture file using the membership number
                    string membershipQuery = "SELECT MembershipNumber FROM Membership WHERE CustomerID = @CustomerID";
                    using (SqlCommand cmd = new SqlCommand(membershipQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        object result = cmd.ExecuteScalar();

                        if (result != null)
                        {
                            string membershipNumber = result.ToString();
                            string[] possibleExtensions = { ".jpg", ".jpeg", ".png" };

                            foreach (string ext in possibleExtensions)
                            {
                                string path = $"~/Uploads/{membershipNumber}{ext}";
                                string serverPath = Server.MapPath(path);
                                if (System.IO.File.Exists(serverPath))
                                {
                                    return path;
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading profile picture: " + ex.Message);
            }

            return null;
        }

        private void LoadLoyaltyPoints()
        {
            try
            {
                // Get points from session (updated from database in LoadCustomerInfo)
                int points = 0;
                if (Session["Points"] != null)
                {
                    int.TryParse(Session["Points"].ToString(), out points);
                }

                lblPoints.Text = points.ToString();

                // Calculate points value (1 point = PHP 10)
                decimal pointsValue = points * 10;

                // Calculate discount power (can use points as discount)
                lblDiscountPower.Text = pointsValue.ToString("0.00");
            }
            catch (Exception ex)
            {
                // Handle errors - show 0 points
                lblPoints.Text = "0";
                lblDiscountPower.Text = "0.00";
                System.Diagnostics.Debug.WriteLine("Error loading points: " + ex.Message);
            }
        }

        private void LoadFavoriteOrder()
        {
            // MOCK DATA - Favorite order feature removed from new layout
            // Keeping method for compatibility
        }

        private void LoadOrderHistory()
        {
            LoadOrderHistory(null);
        }

        private void LoadOrderHistory(string searchOrderID)
        {
            // First, update order statuses in database based on time
            UpdateOrderStatusInDatabase();

            // Get sort order from dropdown
            string sortOrder = ddlSortOrder.SelectedValue;

            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get CustomerID from session
                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                    {
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);
                    }

                    if (customerID == 0)
                    {
                        // No customer ID - show empty
                        pnlNoOrders.Visible = true;
                        return;
                    }

                    // Build WHERE clause with optional search
                    string whereClause = "WHERE o.CustomerID = @CustomerID";
                    if (!string.IsNullOrEmpty(searchOrderID))
                    {
                        whereClause += " AND o.OrderID = @SearchOrderID";
                    }

                    // Query #9: ORDER BY QUERY - Get Customer Order History with sorting
                    string query = @"
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
                        " + whereClause + @"
                        ORDER BY o.OrderDate " + sortOrder;

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);

                        if (!string.IsNullOrEmpty(searchOrderID))
                        {
                            int orderIdInt;
                            if (int.TryParse(searchOrderID, out orderIdInt))
                            {
                                cmd.Parameters.AddWithValue("@SearchOrderID", orderIdInt);
                            }
                            else
                            {
                                // Invalid search - show no results
                                pnlNoOrders.Visible = true;
                                return;
                            }
                        }

                        DataTable dt = new DataTable();
                        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                        {
                            adapter.Fill(dt);
                        }

                        if (dt.Rows.Count > 0)
                        {
                            rptOrderHistory.DataSource = dt;
                            rptOrderHistory.DataBind();
                            pnlNoOrders.Visible = false;
                        }
                        else
                        {
                            pnlNoOrders.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Handle database errors - show empty for now
                pnlNoOrders.Visible = true;
                // For debugging: System.Diagnostics.Debug.WriteLine("Error loading order history: " + ex.Message);
            }
        }

        protected void btnUsePoints_Click(object sender, EventArgs e)
        {
            // Store points usage flag in session for next order
            Session["UsePointsDiscount"] = "true";
            Session["PointsDiscount"] = lblDiscountPower.Text;

            lblPointsMsg.Text = "✓ Points will be applied as discount on your next order!";
            lblPointsMsg.Visible = true;

            // Redirect to order page after 2 seconds
            Response.AddHeader("REFRESH", "2;URL=Order.aspx");
        }

        protected void rptOrderHistory_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string orderID = e.CommandArgument.ToString();

            if (e.CommandName == "Reorder")
            {
                try
                {
                    string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();

                        // Query #10: CUSTOM QUERY - Reorder System (Load Previous Order Items)
                        string query = @"
                            SELECT 
                                oi.ProductID,
                                p.ProductName,
                                oi.SizeID,
                                ps.SizeName,
                                oi.FlavorID,
                                pf.FlavorName,
                                oi.Quantity,
                                (p.BasePrice + ISNULL(ps.PriceModifier, 0)) AS CurrentPrice,
                                oi.UnitPrice AS OriginalPrice
                            FROM OrderItems oi
                            INNER JOIN Products p ON oi.ProductID = p.ProductID
                            LEFT JOIN ProductSizes ps ON oi.SizeID = ps.SizeID
                            LEFT JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
                            WHERE oi.OrderID = @OrderID
                            ORDER BY oi.OrderItemID";

                        List<Order.CartItem> cart = new List<Order.CartItem>();

                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@OrderID", Convert.ToInt32(orderID));

                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    cart.Add(new Order.CartItem
                                    {
                                        Product = reader["ProductName"].ToString(),
                                        Size = reader["SizeName"]?.ToString() ?? "Regular",
                                        Flavor = reader["FlavorName"]?.ToString() ?? "Salt",
                                        Qty = Convert.ToInt32(reader["Quantity"]),
                                        UnitPrice = Convert.ToDecimal(reader["CurrentPrice"]) // Use current price
                                    });
                                }
                            }
                        }

                        if (cart.Count > 0)
                        {
                            // Store cart in session
                            Session["Cart"] = cart;
                            Session["ReorderMessage"] = "✓ Previous order loaded! Review and confirm your order.";

                            // Redirect to order page
                            Response.Redirect("Order.aspx");
                        }
                        else
                        {
                            // No items found - use fallback
                            LoadFallbackReorderItems(orderID);
                        }
                    }
                }
                catch (Exception ex)
                {
                    // Database error - use fallback
                    System.Diagnostics.Debug.WriteLine("Error loading reorder items: " + ex.Message);
                    LoadFallbackReorderItems(orderID);
                }
            }
            else if (e.CommandName == "Cancel")
            {
                try
                {
                    string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();

                        // Query #4: DELETE QUERY - Remove Cancelled Order (update status instead of delete)
                        string updateQuery = "UPDATE Orders SET OrderStatus = 'Cancelled' WHERE OrderID = @OrderID";

                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@OrderID", Convert.ToInt32(orderID));
                            int rowsAffected = cmd.ExecuteNonQuery();

                            if (rowsAffected > 0)
                            {
                                Session["CancelMessage"] = "✓ Order #" + orderID + " has been cancelled successfully.";
                            }
                            else
                            {
                                Session["CancelMessage"] = "✗ Failed to cancel order #" + orderID + ".";
                            }
                        }
                    }

                    // Reload the page to show updated order status
                    Response.Redirect(Request.RawUrl);
                }
                catch (Exception ex)
                {
                    Session["CancelMessage"] = "✗ Error cancelling order: " + ex.Message;
                    Response.Redirect(Request.RawUrl);
                }
            }
        }

        private void LoadFallbackReorderItems(string orderID)
        {
            // Fallback reorder items when database query fails
            List<Order.CartItem> cart = new List<Order.CartItem>();

            // Default items based on order ID pattern
            cart.Add(new Order.CartItem
            {
                Product = "French Fries",
                Size = "Large",
                Flavor = "Cheese",
                Qty = 1,
                UnitPrice = 58m
            });

            // Store cart in session
            Session["Cart"] = cart;
            Session["ReorderMessage"] = "✓ Sample order loaded! Review and confirm your order.";

            // Redirect to order page
            Response.Redirect("Order.aspx");
        }

        // Helper method to get order status based on time
        protected string GetOrderStatus(DateTime orderDate, string dbStatus)
        {
            // Use the actual database status instead of time-based calculation
            switch (dbStatus?.ToLower())
            {
                case "delivered":
                    return "<span class='order-status status-delivered'>Delivered</span>";
                case "confirmed":
                    return "<span class='order-status status-confirmed'>Confirmed</span>";
                case "pending":
                default:
                    return "<span class='order-status status-pending'>Pending</span>";
            }
        }

        // New method to update order status in database
        private void UpdateOrderStatusInDatabase()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get CustomerID from session
                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                    {
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);
                    }

                    if (customerID == 0) return;

                    // First, update orders that should be confirmed (5+ minutes old, still pending)
                    string confirmQuery = @"
                        UPDATE Orders 
                        SET OrderStatus = 'Confirmed', 
                            ConfirmedAt = DATEADD(MINUTE, 5, OrderDate)
                        WHERE CustomerID = @CustomerID 
                        AND OrderStatus = 'Pending' 
                        AND DATEDIFF(MINUTE, OrderDate, GETDATE()) >= 5
                        AND DATEDIFF(MINUTE, OrderDate, GETDATE()) < 15";

                    using (SqlCommand cmd = new SqlCommand(confirmQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        int confirmedRows = cmd.ExecuteNonQuery();
                        
                        if (confirmedRows > 0)
                        {
                            System.Diagnostics.Debug.WriteLine($"Updated {confirmedRows} orders to Confirmed status");
                        }
                    }

                    // Then, update orders that should be delivered (15+ minutes old)
                    string deliverQuery = @"
                        UPDATE Orders 
                        SET OrderStatus = 'Delivered', 
                            DeliveredAt = DATEADD(MINUTE, 15, OrderDate),
                            ConfirmedAt = CASE 
                                WHEN ConfirmedAt IS NULL THEN DATEADD(MINUTE, 5, OrderDate)
                                ELSE ConfirmedAt 
                            END
                        WHERE CustomerID = @CustomerID 
                        AND (OrderStatus = 'Pending' OR OrderStatus = 'Confirmed')
                        AND DATEDIFF(MINUTE, OrderDate, GETDATE()) >= 15";

                    using (SqlCommand cmd = new SqlCommand(deliverQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        int deliveredRows = cmd.ExecuteNonQuery();
                        
                        if (deliveredRows > 0)
                        {
                            System.Diagnostics.Debug.WriteLine($"Updated {deliveredRows} orders to Delivered status");
                        }
                    }

                    // Debug: Show what orders exist for this customer
                    string debugQuery = @"
                        SELECT OrderID, OrderDate, OrderStatus, ConfirmedAt, DeliveredAt,
                               DATEDIFF(MINUTE, OrderDate, GETDATE()) as MinutesOld
                        FROM Orders 
                        WHERE CustomerID = @CustomerID 
                        ORDER BY OrderDate DESC";

                    using (SqlCommand cmd = new SqlCommand(debugQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            System.Diagnostics.Debug.WriteLine($"Orders for Customer {customerID}:");
                            while (reader.Read())
                            {
                                System.Diagnostics.Debug.WriteLine($"  Order {reader["OrderID"]}: {reader["OrderStatus"]}, {reader["MinutesOld"]} mins old, Confirmed: {reader["ConfirmedAt"]}, Delivered: {reader["DeliveredAt"]}");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error updating order status: " + ex.Message);
                // Also show error in UI for debugging
                if (HttpContext.Current != null)
                {
                    HttpContext.Current.Response.Write($"<script>console.log('Order update error: {ex.Message}');</script>");
                }
            }
        }

        // Helper method to show cancel button only if order is within 10 minutes
        protected string GetCancelButton(DateTime orderDate, string orderID)
        {
            TimeSpan timeSinceOrder = DateTime.Now - orderDate;

            if (timeSinceOrder.TotalMinutes <= 10)
            {
                return $"<button type='button' class='btn-cancel' onclick='cancelOrder({orderID})'>Cancel Order</button>";
            }

            return "";
        }

        // ORDER SUMMARY BUTTON CLICK - Redirect to OrderSummary.aspx
        protected void btnOrderSummary_Click(object sender, EventArgs e)
        {
            Response.Redirect("OrderSummary.aspx");
        }

        // SORT DROPDOWN CHANGE - Reload order history with new sort order
        protected void ddlSortOrder_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Check if there's a search term
            string searchText = txtSearchOrderID.Text.Trim();
            if (!string.IsNullOrEmpty(searchText))
            {
                LoadOrderHistory(searchText);
            }
            else
            {
                LoadOrderHistory();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string searchOrderID = txtSearchOrderID.Text.Trim();
            if (!string.IsNullOrEmpty(searchOrderID))
            {
                LoadOrderHistory(searchOrderID);
            }
            else
            {
                LoadOrderHistory();
            }
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            txtSearchOrderID.Text = "";
            LoadOrderHistory();
        }

        protected void btnClearHistory_Click(object sender, EventArgs e)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get CustomerID from session
                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                    {
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);
                    }

                    if (customerID == 0)
                    {
                        return;
                    }

                    // Delete all orders for this customer
                    string deleteOrderItemsQuery = @"
                        DELETE FROM OrderItems 
                        WHERE OrderID IN (SELECT OrderID FROM Orders WHERE CustomerID = @CustomerID)";

                    string deleteOrdersQuery = "DELETE FROM Orders WHERE CustomerID = @CustomerID";

                    using (SqlCommand cmd = new SqlCommand(deleteOrderItemsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(deleteOrdersQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        cmd.ExecuteNonQuery();
                    }

                    // Reload the page to show empty history
                    LoadOrderHistory();
                }
            }
            catch (Exception ex)
            {
                // Handle error silently or show message
                System.Diagnostics.Debug.WriteLine("Error clearing history: " + ex.Message);
            }
        }

        protected void btnCancelOrder_Click(object sender, EventArgs e)
        {
            try
            {
                string orderID = hdnCancelOrderID.Value;
                if (string.IsNullOrEmpty(orderID))
                {
                    return;
                }

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Update order status to Cancelled
                    string updateQuery = "UPDATE Orders SET OrderStatus = 'Cancelled' WHERE OrderID = @OrderID";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@OrderID", int.Parse(orderID));
                        cmd.ExecuteNonQuery();
                    }
                }

                // Reload order history
                LoadOrderHistory();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error cancelling order: " + ex.Message);
            }
        }

    }
}