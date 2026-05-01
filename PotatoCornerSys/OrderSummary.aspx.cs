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
    public partial class OrderSummary : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadOrderSummary("All");
            }
        }

        protected void ddlDeliveryFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            string filterType = ddlDeliveryFilter.SelectedValue;
            LoadOrderSummary(filterType);
        }

        private void LoadOrderSummary(string deliveryFilter)
        {
            try
            {
                // Get CustomerID from session
                int currentCustomerID = 0;
                if (Session["CustomerID"] != null)
                {
                    int.TryParse(Session["CustomerID"].ToString(), out currentCustomerID);
                }

                if (currentCustomerID == 0)
                {
                    // No customer logged in - show zero data
                    SetAllLabelsToZero();
                    return;
                }

                // Check if connection string exists
                string connectionString = null;
                try
                {
                    connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"]?.ConnectionString;
                }
                catch
                {
                    // Connection string not configured
                }

                if (string.IsNullOrEmpty(connectionString))
                {
                    // No database connection - show mock data
                    LoadMockData(deliveryFilter);
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Query #8: COUNT/AGGREGATE QUERY - Order Summary Statistics
                    string query = @"
                        SELECT 
                            COUNT(*) AS TotalOrders,
                            ISNULL(SUM(TotalAmount), 0) AS TotalSpent,
                            ISNULL(AVG(TotalAmount), 0) AS AverageOrderValue,
                            ISNULL(MIN(TotalAmount), 0) AS SmallestOrder,
                            ISNULL(MAX(TotalAmount), 0) AS LargestOrder
                        FROM Orders 
                        WHERE CustomerID = @CustomerID 
                            AND OrderStatus != 'Cancelled'
                            AND (@DeliveryFilter = 'All' OR DeliveryType = @DeliveryFilter)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", currentCustomerID);
                        cmd.Parameters.AddWithValue("@DeliveryFilter", deliveryFilter);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Overall Statistics
                                lblTotalOrders.Text = reader["TotalOrders"].ToString();
                                lblTotalSpent.Text = Convert.ToDecimal(reader["TotalSpent"]).ToString("0.00");
                                lblAverageOrder.Text = Convert.ToDecimal(reader["AverageOrderValue"]).ToString("0.00");
                                lblLargestOrder.Text = Convert.ToDecimal(reader["LargestOrder"]).ToString("0.00");
                            }
                            else
                            {
                                // No data found - set all to zero
                                SetAllLabelsToZero();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Handle error - show mock data instead
                LoadMockData(deliveryFilter);
            }
        }
        private void LoadMockData(string deliveryFilter)
        {
            // Mock data for demonstration - replace when database is connected
            lblTotalOrders.Text = "0";
            lblTotalSpent.Text = "0.00";
            lblAverageOrder.Text = "0.00";
            lblLargestOrder.Text = "0.00";
        }

        private void SetAllLabelsToZero()
        {
            lblTotalOrders.Text = "0";
            lblTotalSpent.Text = "0.00";
            lblAverageOrder.Text = "0.00";
            lblLargestOrder.Text = "0.00";
        }
    }
}