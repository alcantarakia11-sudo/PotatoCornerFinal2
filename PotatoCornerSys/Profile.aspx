<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="PotatoCornerSys.Profile" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
        <title>Potato Corner - My Profile</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: #e8e8e8;
            min-height: 100vh;
        }
        
        /* NAVBAR */
        .navbar { 
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%); 
            padding: 15px 50px; 
            display: flex; 
            align-items: center;
            justify-content: space-between; 
            border-bottom: 5px solid #f5c800;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        
        .navbar-logo img { 
            height: 85px;
            filter: drop-shadow(0 2px 6px rgba(0,0,0,0.2));
            transition: transform 0.3s;
        }
        
        .navbar-logo img:hover {
            transform: scale(1.05);
        }
        
        .navbar-links { 
            display: flex; 
            align-items: center;
            gap: 40px;
            list-style: none;
        }
        
        .navbar-links a { 
            color: white; 
            text-decoration: none; 
            font-size: 16px;
            font-weight: 700; 
            letter-spacing: 0.5px;
            transition: all 0.3s;
            position: relative;
        }
        
        .navbar-links a:hover { 
            color: #f5c800;
            transform: translateY(-2px);
        }
        
        .navbar-links a::after {
            content: '';
            position: absolute;
            bottom: -5px;
            left: 0;
            width: 0;
            height: 3px;
            background: #f5c800;
            transition: width 0.3s;
        }
        
        .navbar-links a:hover::after {
            width: 100%;
        }
        
        /* HERO BANNER */
        .hero-banner {
            background: #e8e8e8;
            padding: 30px 40px 50px 40px;
        }
        
        .hero-content {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .profile-header {
            background: linear-gradient(135deg, #e8401c 0%, #ff6b47 100%);
            padding: 25px 40px;
            border-radius: 16px;
            text-align: center;
            box-shadow: 0 6px 20px rgba(232,64,28,0.3);
        }
        
        .profile-header h1 {
            font-size: 42px;
            font-weight: 900;
            color: white;
            text-transform: uppercase;
            letter-spacing: 4px;
            text-shadow: 0 3px 15px rgba(0,0,0,0.2);
            margin-bottom: 0;
        }
        
        /* MAIN CONTAINER */
        .profile-container { 
            max-width: 1400px; 
            margin: 40px auto; 
            padding: 0 40px;
        }
        
        /* 2-COLUMN GRID */
        .top-grid {
            display: grid;
            grid-template-columns: 350px 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }
        
        /* CARD STYLES */
        .card {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .card-header {
            font-size: 13px;
            color: #119247;
            font-weight: 700;
            text-transform: uppercase;
            margin-bottom: 24px;
            letter-spacing: 0.5px;
        }
        
        /* LEFT: CUSTOMER INFO */
        .customer-info {
            text-align: center;
        }
        
        .avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            border: 4px solid #119247;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            font-weight: 900;
            color: white;
            margin: 0 auto 16px;
        }
        
        .customer-name {
            font-size: 22px;
            font-weight: 800;
            color: #333;
            margin-bottom: 10px;
        }
        
        .membership-badge {
            display: inline-block;
            padding: 8px 20px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            background: #119247;
            color: white;
            margin-bottom: 24px;
        }
        
        .membership-badge.royalty {
            background: linear-gradient(135deg, #f5c800 0%, #ffd700 100%);
            color: #333;
            box-shadow: 0 4px 15px rgba(245, 200, 0, 0.4);
        }
        
        .info-list {
            text-align: left;
            border-top: 2px solid #e8e8e8;
            padding-top: 20px;
        }
        
        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #f0f0f0;
            font-size: 13px;
        }
        
        .info-item:last-child {
            border-bottom: none;
        }
        
        .info-label {
            color: #666;
            font-weight: 600;
        }
        
        .info-value {
            color: #333;
            font-weight: 700;
            text-align: right;
        }
        
        .btn-logout {
            width: 100%;
            background: white;
            color: #e8401c;
            border: 2px solid #e8401c;
            padding: 12px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            margin-top: 20px;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .btn-logout:hover {
            background: #e8401c;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(232,64,28,0.3);
        }
        
        /* MODAL STYLES */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.6);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }
        
        .modal-overlay.active {
            display: flex;
        }
        
        .modal-box {
            background: white;
            border-radius: 16px;
            padding: 32px;
            max-width: 400px;
            width: 90%;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            animation: modalSlideIn 0.3s ease-out;
        }
        
        @keyframes modalSlideIn {
            from {
                transform: translateY(-50px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }
        
        .modal-header {
            font-size: 22px;
            font-weight: 800;
            color: #333;
            margin-bottom: 16px;
            text-align: center;
        }
        
        .modal-message {
            font-size: 14px;
            color: #666;
            margin-bottom: 28px;
            text-align: center;
            line-height: 1.6;
        }
        
        .modal-buttons {
            display: flex;
            gap: 12px;
        }
        
        .modal-btn {
            flex: 1;
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .modal-btn-cancel {
            background: #e8e8e8;
            color: #666;
        }
        
        .modal-btn-cancel:hover {
            background: #d0d0d0;
        }
        
        .modal-btn-confirm {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
        }
        
        .modal-btn-confirm:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(232,64,28,0.4);
        }
        
        /* RIGHT: AVAILABLE POINTS */
        .points-section {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            text-align: center;
            padding: 40px;
        }
        
        .points-header {
            font-size: 16px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 20px;
            color: white;
        }
        
        .points-display {
            font-size: 100px;
            font-weight: 900;
            color: #fac775;
            line-height: 1;
            margin-bottom: 10px;
        }
        
        .points-label {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 40px;
            color: white;
        }
        
        .discount-box {
            background: linear-gradient(135deg, #fac775 0%, #ffd700 100%);
            color: #633806;
            padding: 24px;
            border-radius: 10px;
            margin-bottom: 24px;
        }
        
        .discount-label {
            font-size: 12px;
            text-transform: uppercase;
            font-weight: 700;
            margin-bottom: 10px;
        }
        
        .discount-amount {
            font-size: 42px;
            font-weight: 900;
        }
        
        .btn-use-points {
            width: 100%;
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            border: none;
            padding: 18px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 800;
            cursor: pointer;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            transition: all 0.3s;
        }
        
        .btn-use-points:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(232,64,28,0.4);
        }
        
        /* ORDER HISTORY TABLE */
        .history-section {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .history-header {
            font-size: 13px;
            color: #119247;
            font-weight: 700;
            text-transform: uppercase;
            margin-bottom: 24px;
            letter-spacing: 0.5px;
        }
        
        .order-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .order-table thead {
            background: #f5f5f5;
        }
        
        .order-table th {
            padding: 14px 16px;
            text-align: left;
            font-size: 11px;
            font-weight: 700;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .order-table td {
            padding: 18px 16px;
            border-bottom: 1px solid #e8e8e8;
            font-size: 13px;
        }
        
        .order-table tbody tr:hover {
            background: #f9f9f9;
        }
        
        .order-id {
            font-weight: 700;
            color: #333;
        }
        
        .order-date {
            color: #666;
            font-size: 12px;
        }
        
        .order-items {
            color: #666;
            font-size: 12px;
        }
        
        .order-total {
            font-weight: 800;
            color: #119247;
        }
        
        .order-status {
            display: inline-block;
            padding: 5px 14px;
            border-radius: 12px;
            font-size: 10px;
            font-weight: 700;
        }
        
        .status-completed {
            background: #d4edda;
            color: #155724;
        }
        
        .status-delivered {
            background: #cce5ff;
            color: #004085;
        }
        
        .status-pending {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-preparing {
            background: #f0f0f0;
            color: #495057;
        }
        
        .status-ready {
            background: #d1ecf1;
            color: #0c5460;
        }
        
        .status-cancelled {
            background: #f8d7da;
            color: #721c24;
        }
        
        .btn-cancel {
            background: #dc3545;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            margin-left: 6px;
        }
        
        .btn-cancel:hover {
            background: #c82333;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(220,53,69,0.3);
        }
        
        .btn-reorder {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            margin-right: 6px;
        }
        
        .btn-reorder:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(17,146,71,0.3);
        }
        
        .btn-clear-history {
            background: #dc3545;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            margin-right: 6px;
        }
        
        .btn-clear-history:hover {
            background: #c82333;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(220,53,69,0.3);
        }
        
        .search-textbox {
            padding: 8px 12px;
            border: 2px solid #e0e0e0;
            border-radius: 6px;
            font-size: 13px;
            width: 200px;
            outline: none;
            transition: all 0.3s;
        }
        
        .search-textbox:focus {
            border-color: #119247;
            box-shadow: 0 0 0 3px rgba(17,146,71,0.1);
        }
        
        .btn-search {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-search:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(17,146,71,0.3);
        }
        
        .btn-clear-search {
            background: #6c757d;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-clear-search:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        
        .btn-cancel {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-cancel:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(232,64,28,0.3);
        }
        
        /* ORDER SUMMARY BUTTON */
        .btn-order-summary {
            background: linear-gradient(135deg, #f5c800 0%, #ffd700 100%);
            color: #333;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .btn-order-summary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(245,200,0,0.4);
        }
        
        /* SORT DROPDOWN */
        .sort-dropdown {
            background: white;
            border: 2px solid #e0e0e0;
            border-radius: 6px;
            padding: 8px 12px;
            font-size: 12px;
            font-weight: 600;
            color: #333;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .sort-dropdown:focus {
            border-color: #119247;
            outline: none;
        }
        
        .view-all {
            text-align: center;
            margin-top: 24px;
        }
        
        .view-all a {
            color: #119247;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
        }
        
        .view-all a:hover {
            text-decoration: underline;
        }
        
        /* RESPONSIVE */
        @media (max-width: 1200px) {
            .top-grid {
                grid-template-columns: 1fr;
            }
        }

        /* CANCEL ORDER MODAL STYLES */
        .cancel-modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.75);
            z-index: 10000;
            justify-content: center;
            align-items: center;
            backdrop-filter: blur(8px);
        }

        .cancel-modal-container {
            animation: cancelModalSlideIn 0.4s ease-out;
        }

        @keyframes cancelModalSlideIn {
            from {
                transform: translateY(-30px) scale(0.95);
                opacity: 0;
            }
            to {
                transform: translateY(0) scale(1);
                opacity: 1;
            }
        }

        .cancel-modal-content {
            background: white;
            border-radius: 20px;
            padding: 35px 30px;
            max-width: 480px;
            width: 90%;
            box-shadow: 0 25px 70px rgba(0, 0, 0, 0.4);
            text-align: center;
            position: relative;
            border: 3px solid #e8401c;
        }

        .cancel-modal-icon {
            margin-bottom: 20px;
        }

        .cancel-modal-icon svg {
            filter: drop-shadow(0 4px 8px rgba(232, 64, 28, 0.2));
        }

        .cancel-modal-header h2 {
            color: #e8401c;
            font-size: 24px;
            font-weight: 900;
            margin: 0 0 15px 0;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .cancel-modal-body {
            margin-bottom: 30px;
        }

        .cancel-modal-body p {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
            margin: 0 0 12px 0;
        }

        .cancel-modal-body p:first-child {
            font-weight: 700;
            color: #333;
            font-size: 16px;
        }

        .cancel-warning {
            background: linear-gradient(135deg, #fff3e0 0%, #ffebee 100%);
            border: 2px solid #ff9800;
            border-radius: 10px;
            padding: 12px 15px;
            margin-top: 15px;
        }

        .warning-text {
            color: #e65100;
            font-size: 13px;
            font-weight: 700;
        }

        .cancel-modal-buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
        }

        .btn-cancel-confirm,
        .btn-cancel-close {
            padding: 14px 24px;
            border: none;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            min-width: 140px;
        }

        .btn-cancel-confirm {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(232, 64, 28, 0.4);
        }

        .btn-cancel-confirm:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(232, 64, 28, 0.5);
        }

        .btn-cancel-close {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(17, 146, 71, 0.4);
        }

        .btn-cancel-close:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(17, 146, 71, 0.5);
        }

        /* Responsive cancel modal */
        @media (max-width: 480px) {
            .cancel-modal-content {
                padding: 25px 20px;
                margin: 20px;
            }
            
            .cancel-modal-buttons {
                flex-direction: column;
            }
            
            .btn-cancel-confirm,
            .btn-cancel-close {
                width: 100%;
            }
        }
    </style>
    <script type="text/javascript">
        var currentOrderID = null;

        function cancelOrder(orderID) {
            currentOrderID = orderID;
            showCancelModal();
        }

        function showCancelModal() {
            document.getElementById('cancelOrderModal').style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }

        function closeCancelModal() {
            document.getElementById('cancelOrderModal').style.display = 'none';
            document.body.style.overflow = 'auto';
            currentOrderID = null;
        }

        function confirmCancelOrder() {
            if (currentOrderID) {
                document.getElementById('<%= hdnCancelOrderID.ClientID %>').value = currentOrderID;
                document.getElementById('<%= btnCancelOrderHidden.ClientID %>').click();
            }
        }

        // Close modal when clicking outside
        document.addEventListener('DOMContentLoaded', function() {
            var modal = document.getElementById('cancelOrderModal');
            if (modal) {
                modal.addEventListener('click', function(e) {
                    if (e.target === this) {
                        closeCancelModal();
                    }
                });
            }
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Hidden fields for cancel functionality -->
        <asp:HiddenField ID="hdnCancelOrderID" runat="server" />
        <asp:Button ID="btnCancelOrderHidden" runat="server" style="display:none;" OnClick="btnCancelOrder_Click" />
        
        <div class="navbar">
            <div class="navbar-logo">
                <img src="logopotcor.png" alt="Potato Corner" />
            </div>
            <ul class="navbar-links">
                <li><a href="Default.aspx">Home</a></li>
                <li><a href="Menu.aspx">Menu</a></li>
                <li><a href="Membership.aspx">Membership</a></li>
                <li><a href="AboutUs.aspx">About Us</a></li>
                <li><a href="Order.aspx">Order Now</a></li>
                <li><a href="Profile.aspx">Profile</a></li>
            </ul>
        </div>
        
        <!-- HERO BANNER -->
        <div class="hero-banner">
            <div class="hero-content">
                <div class="profile-header">
                    <h1>MY PROFILE</h1>
                </div>
            </div>
        </div>
        
        <!-- MAIN PROFILE CONTAINER -->
        <div class="profile-container">
            
            <!-- TOP: 2-COLUMN GRID -->
            <div class="top-grid">
                
                <!-- LEFT: CUSTOMER INFO -->
                <div class="card customer-info">
                    <div class="card-header">CUSTOMER INFO</div>
                    
                    <div class="avatar">
                        <asp:Image ID="imgProfilePic" runat="server" Visible="false" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;" />
                        <asp:Label ID="lblInitials" runat="server" Text="JD" />
                    </div>
                    
                    <div class="customer-name">
                        <asp:Label ID="lblFullName" runat="server" Text="Juan Dela Cruz" />
                    </div>
                    
                    <asp:Label ID="lblMembershipBadge" runat="server" CssClass="membership-badge" Text="ROYALTY MEMBER" />
                    
                    <div class="info-list">
                        <div class="info-item">
                            <span class="info-label">Email</span>
                            <span class="info-value"><asp:Label ID="lblEmailAvatar" runat="server" Text="juan.delacruz@email.com" /></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Phone</span>
                            <span class="info-value"><asp:Label ID="lblInfoPhone" runat="server" Text="09123456789" /></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Address</span>
                            <span class="info-value"><asp:Label ID="lblInfoAddress" runat="server" Text="123 Main Street, Manila" /></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Member Since</span>
                            <span class="info-value"><asp:Label ID="lblMemberSince" runat="server" Text="Jan 15, 2026" /></span>
                        </div>
                        <div class="info-item" id="royaltyNumberSection" runat="server" visible="false">
                            <span class="info-label">Royalty Number</span>
                            <span class="info-value" style="font-weight: 700; color: #119247;"><asp:Label ID="lblRoyaltyNumber" runat="server" Text="N/A" /></span>
                        </div>
                    </div>
                    
                    <asp:Button ID="btnLogout" runat="server" 
                        Text="LOG OUT" 
                        CssClass="btn-logout" 
                        OnClientClick="showLogoutModal(); return false;" />
                </div>
                
                <!-- RIGHT: AVAILABLE POINTS -->
                <div class="card points-section">
                    <div class="points-header">AVAILABLE POINTS</div>
                    <div class="points-display">
                        <asp:Label ID="lblPoints" runat="server" Text="250" />
                    </div>
                    <div class="points-label">pts</div>
                    
                    <div class="discount-box">
                        <div class="discount-label">YOUR DISCOUNT POWER</div>
                        <div class="discount-amount">PHP <asp:Label ID="lblDiscountPower" runat="server" Text="2500.00" /></div>
                    </div>
                    
                    <asp:Button ID="btnUsePoints" runat="server" 
                        Text="USE POINTS ON NEXT ORDER" 
                        CssClass="btn-use-points" 
                        OnClick="btnUsePoints_Click" />
                    <asp:Label ID="lblPointsMsg" runat="server" 
                        Visible="false" 
                        Style="display:block; text-align:center; margin-top:12px; font-size:12px; color:white; font-weight:700;"></asp:Label>
                </div>
                
            </div><!-- end top-grid -->
            
            <!-- BOTTOM: ORDER HISTORY -->
            <div class="history-section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                    <div class="history-header">ORDER HISTORY & QUICK REORDER</div>
                    <div style="display: flex; gap: 15px; align-items: center;">
                        <!-- ORDER SUMMARY BUTTON -->
                        <asp:Button ID="btnOrderSummary" runat="server" 
                            Text="Order Summary" 
                            CssClass="btn-order-summary" 
                            OnClick="btnOrderSummary_Click" />
                        
                        <!-- CLEAR HISTORY BUTTON -->
                        <asp:Button ID="btnClearHistory" runat="server" 
                            Text="Clear History" 
                            CssClass="btn-clear-history" 
                            OnClick="btnClearHistory_Click"
                            OnClientClick="return confirm('Are you sure you want to clear all order history? This action cannot be undone.');" />
                        
                        <!-- SORT DROPDOWN -->
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <span style="font-size: 12px; color: #666; font-weight: 600;">Sort by:</span>
                            <asp:DropDownList ID="ddlSortOrder" runat="server" 
                                CssClass="sort-dropdown" 
                                AutoPostBack="true" 
                                OnSelectedIndexChanged="ddlSortOrder_SelectedIndexChanged">
                                <asp:ListItem Value="DESC" Text="Most Recent" Selected="True" />
                                <asp:ListItem Value="ASC" Text="Oldest First" />
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
                
                <!-- SEARCH SECTION -->
                <div style="display: flex; gap: 15px; align-items: center; margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 8px;">
                    <span style="font-size: 14px; color: #666; font-weight: 600;">Search by Order ID:</span>
                    <asp:TextBox ID="txtSearchOrderID" runat="server" 
                        CssClass="search-textbox" 
                        placeholder="Enter Order ID (e.g., 123)" />
                    <asp:Button ID="btnSearch" runat="server" 
                        Text="Search" 
                        CssClass="btn-search" 
                        OnClick="btnSearch_Click" />
                    <asp:Button ID="btnClearSearch" runat="server" 
                        Text="Clear" 
                        CssClass="btn-clear-search" 
                        OnClick="btnClearSearch_Click" />
                </div>
                
                <asp:Panel ID="pnlNoOrders" runat="server" Visible="false">
                    <div style="text-align:center; padding:40px; color:#999;">
                        No orders yet. Start ordering to see your history here!
                    </div>
                </asp:Panel>
                
                <table class="order-table">
                    <thead>
                        <tr>
                            <th>ORDER #</th>
                            <th>DATE</th>
                            <th>ITEMS</th>
                            <th>TOTAL</th>
                            <th>STATUS</th>
                            <th>ACTION</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptOrderHistory" runat="server" OnItemCommand="rptOrderHistory_ItemCommand">
                            <ItemTemplate>
                                <tr>
                                    <td class="order-id">#PC-<%# Eval("OrderID") %></td>
                                    <td class="order-date">
                                        <%# Eval("OrderDate", "{0:MMM dd, yyyy}") %><br />
                                        <%# Eval("OrderDate", "{0:h:mm tt}") %>
                                    </td>
                                    <td class="order-items"><%# Eval("ItemsSummary") %></td>
                                    <td class="order-total">PHP <%# Eval("TotalAmount", "{0:0.00}") %></td>
                                    <td>
                                        <%# GetOrderStatus((DateTime)Eval("OrderDate"), Eval("OrderStatus").ToString()) %>
                                    </td>
                                    <td>
                                        <asp:Button runat="server" 
                                            Text="Reorder" 
                                            CssClass="btn-reorder" 
                                            CommandName="Reorder" 
                                            CommandArgument='<%# Eval("OrderID") %>' />
                                        <%# GetCancelButton((DateTime)Eval("OrderDate"), Eval("OrderID").ToString()) %>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
                
                <div class="view-all">
                    <a href="#">View All Orders</a>
                </div>
            </div>
            
        </div><!-- end profile-container -->
        
        <!-- LOGOUT CONFIRMATION MODAL -->
        <div id="logoutModal" class="modal-overlay">
            <div class="modal-box">
                <div class="modal-header">Log Out</div>
                <div class="modal-message">Are you sure you want to log out of your account?</div>
                <div class="modal-buttons">
                    <button type="button" class="modal-btn modal-btn-cancel" onclick="hideLogoutModal()">Cancel</button>
                    <asp:Button ID="btnConfirmLogout" runat="server" 
                        Text="Log Out" 
                        CssClass="modal-btn modal-btn-confirm" 
                        OnClick="btnLogout_Click" />
                </div>
            </div>
        </div>
        
        <script>
            function showLogoutModal() {
                document.getElementById('logoutModal').classList.add('active');
            }
            
            function hideLogoutModal() {
                document.getElementById('logoutModal').classList.remove('active');
            }
            
            // Close modal when clicking outside
            document.addEventListener('DOMContentLoaded', function() {
                document.getElementById('logoutModal').addEventListener('click', function(e) {
                    if (e.target === this) {
                        hideLogoutModal();
                    }
                });
            });
        </script>
        
        <!-- Cancel Order Modal -->
        <div id="cancelOrderModal" class="cancel-modal-overlay">
            <div class="cancel-modal-container">
                <div class="cancel-modal-content">
                    <div class="cancel-modal-icon">
                        <svg width="70" height="70" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <circle cx="12" cy="12" r="10" stroke="#e8401c" stroke-width="2" fill="#ffebee"/>
                            <path d="M12 8v4M12 16h.01" stroke="#e8401c" stroke-width="2" stroke-linecap="round"/>
                        </svg>
                    </div>
                    <div class="cancel-modal-header">
                        <h2>Cancel Order Confirmation</h2>
                    </div>
                    <div class="cancel-modal-body">
                        <p><strong>Are you sure you want to cancel this order?</strong></p>
                        <p>This action cannot be undone and your order will be permanently cancelled.</p>
                        <div class="cancel-warning">
                            <span class="warning-text">Note: Orders can only be cancelled within 5 minutes of placing</span>
                        </div>
                    </div>
                    <div class="cancel-modal-buttons">
                        <button type="button" class="btn-cancel-confirm" onclick="confirmCancelOrder()">
                            Yes, Cancel Order
                        </button>
                        <button type="button" class="btn-cancel-close" onclick="closeCancelModal()">
                            Keep Order
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- FOOTER -->
        <div style="background: linear-gradient(135deg, #119247 0%, #0d7336 100%); color: white; text-align: center; padding: 40px; margin-top: 50px; border-top: 5px solid #f5c800;">
            <div style="margin-bottom: 20px;">
                <a href="#" style="color: #f5c800; text-decoration: none; margin: 0 15px; font-weight: 600;">Terms & Conditions</a> |
                <a href="#" style="color: #f5c800; text-decoration: none; margin: 0 15px; font-weight: 600;">Privacy Policy</a>
            </div>
            <div style="font-size: 14px; color: #ccc; margin-top: 15px;">© 2026 Potato Corner. All rights reserved.</div>
        </div>
        
    
    </form>
</body>
</html>
