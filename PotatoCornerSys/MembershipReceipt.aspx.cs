using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class MembershipReceipt : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if session data exists
                if (Session["RoyaltyNumber"] == null)
                {
                    Response.Redirect("~/RegisterForm.aspx");
                    return;
                }

                // Load data from session
                lblRoyaltyNumber.Text = Session["RoyaltyNumber"]?.ToString() ?? "";
                lblMemberID.Text = Session["RoyaltyNumber"]?.ToString() ?? "";
                lblFullName.Text = Session["MemberFullName"]?.ToString() ?? "";
                lblEmail.Text = Session["MemberEmail"]?.ToString() ?? "";
                lblContact.Text = Session["MemberContact"]?.ToString() ?? "";
                lblDateJoined.Text = Session["RegistrationDate"]?.ToString() ?? "";
                lblFee.Text = Session["RegistrationFee"]?.ToString() ?? "";
                lblPaymentMethod.Text = Session["PaymentMethod"]?.ToString() ?? "";
                lblAmountPaid.Text = Session["AmountPaid"]?.ToString() ?? "";
                lblChange.Text = Session["ChangeAmount"]?.ToString() ?? "";

                // Load member photo
                if (Session["MemberPicture"] != null)
                {
                    imgMemberPhoto.ImageUrl = Session["MemberPicture"].ToString();
                }
            }
        }

        protected void btnHome_Click(object sender, EventArgs e)
        {
            // Clear only temporary membership registration session data, keep important data
            Session.Remove("MemberFullName");
            Session.Remove("MemberEmail");
            Session.Remove("MemberContact");
            Session.Remove("RegistrationDate");
            Session.Remove("RegistrationFee");
            Session.Remove("PaymentMethod");
            Session.Remove("AmountPaid");
            Session.Remove("ChangeAmount");

            // Keep these for profile display
            // Session["RoyaltyNumber"] - keep for order validation
            // Session["MemberPicture"] - keep for profile picture display

            // Set flag that user now has royalty membership
            Session["HasRoyaltyMembership"] = true;

            Response.Redirect("~/Default.aspx");
        }
    }
    
}