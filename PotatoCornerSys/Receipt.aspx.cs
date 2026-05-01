using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PotatoCornerSys.Order;

namespace PotatoCornerSys
{
    public partial class Receipt : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["OrderName"] == null)
                {
                    Response.Redirect("~/Order.aspx");
                    return;
                }

                // Customer details
                lblName.Text = Session["OrderName"].ToString();
                lblAddress.Text = Session["OrderAddress"].ToString();
                lblContact.Text = Session["OrderContact"].ToString();
                lblDelivery.Text = Session["OrderDelivery"].ToString();
                lblOrderDate.Text = DateTime.Now.ToString("MMMM dd, yyyy hh:mm tt");
                lblOrderNo.Text = new Random().Next(10000, 99999).ToString();

                // Royalty
                bool isRoyalty = Session["OrderIsRoyalty"]?.ToString() == "true";
                pnlRoyalty.Visible = isRoyalty;
                pnlNoRoyalty.Visible = !isRoyalty;
                if (isRoyalty && Session["RoyaltyNo"] != null)
                    lblRoyaltyNo.Text = Session["RoyaltyNo"].ToString();

                // Cart items
                var cart = Session["Cart"] as List<CartItem>;
                if (cart != null && cart.Count > 0)
                {
                    rptItems.DataSource = cart;
                    rptItems.DataBind();

                    decimal subtotal = 0;
                    foreach (var item in cart) subtotal += item.LineTotal;

                    decimal discount = isRoyalty ? subtotal * 0.10m : 0;
                    bool isDelivery = lblDelivery.Text == "Delivery";
                    decimal deliveryFee = isDelivery ? 50m : 0;
                    decimal total = subtotal - discount + deliveryFee;

                    lblSubtotal.Text = subtotal.ToString("0.00");
                    lblDiscount.Text = discount.ToString("0.00");
                    lblDeliveryFee.Text = deliveryFee.ToString("0.00");
                    lblTotal.Text = total.ToString("0.00");
                }

                // Payment & points
                lblPaymentMethod.Text = Session["PaymentMethod"]?.ToString() ?? "-";
                lblAmountPaid.Text = Session["AmountPaid"]?.ToString() ?? "-";
                lblChange.Text = Session["Change"]?.ToString() ?? "0.00";
                lblPointsEarned.Text = Session["PointsEarned"]?.ToString() ?? "0";

                // Clear cart after displaying
                Session["Cart"] = null;
            }
        }

        protected void btnHome_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Default.aspx");
        }
    }
    
}