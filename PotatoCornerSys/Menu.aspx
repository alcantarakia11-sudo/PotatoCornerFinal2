<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Menu.aspx.cs" Inherits="PotatoCornerSys.Menu" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Potato Corner - Menu</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
        }
        
        /* NAVBAR - CONSISTENT ACROSS ALL PAGES */
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
        
        /* HERO BANNER - COMPACT ORANGE BANNER */
        .hero { 
            background: #e8e8e8;
            padding: 30px 40px 50px 40px;
        }
        
        .hero-content {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .hero-banner {
            background: linear-gradient(135deg, #e8401c 0%, #ff6b47 100%);
            padding: 25px 40px;
            border-radius: 16px;
            text-align: center;
            box-shadow: 0 6px 20px rgba(232,64,28,0.3);
        }
        
        .hero-banner h1 { 
            font-size: 42px; 
            color: white; 
            font-weight: 900; 
            text-transform: uppercase; 
            letter-spacing: 4px; 
            text-shadow: 0 3px 15px rgba(0,0,0,0.2);
            margin-bottom: 0;
        }
        
        /* MAIN CONTAINER */
        .menu-container { 
            max-width: 1600px; 
            margin: 50px auto; 
            padding: 0 40px;
        }
        
        /* PRODUCT GRID - 3 COLUMNS */
        .product-grid { 
            display: grid; 
            grid-template-columns: repeat(3, 1fr); 
            gap: 40px;
            margin-bottom: 50px;
        }
        
        /* LARGE GREEN PRODUCT CARD */
        .product-card { 
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%); 
            border-radius: 30px; 
            padding: 0;
            box-shadow: 0 15px 50px rgba(0,0,0,0.25);
            transition: all 0.4s;
            overflow: hidden;
            position: relative;
        }
        
        .product-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 8px;
            background: linear-gradient(90deg, #f5c800 0%, #ffd700 50%, #f5c800 100%);
        }
        
        .product-card:hover { 
            transform: translateY(-10px) scale(1.02); 
            box-shadow: 0 20px 60px rgba(0,0,0,0.35);
        }
        
        /* PRODUCT IMAGE SECTION */
        .product-image { 
            background: white;
            padding: 25px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .product-image::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 5px;
            background: linear-gradient(90deg, #f5c800 0%, #ffd700 100%);
        }
        
        .product-image img { 
            max-width: 100%;
            height: 180px;
            object-fit: contain;
            filter: drop-shadow(0 10px 25px rgba(0,0,0,0.2));
            transition: transform 0.3s;
        }
        
        .product-card:hover .product-image img {
            transform: scale(1.1) rotate(2deg);
        }
        
        /* PRODUCT NAME */
        .product-name { 
            font-size: 28px; 
            color: #f5c800; 
            font-weight: 900; 
            text-transform: uppercase; 
            text-align: center;
            padding: 20px;
            letter-spacing: 2px;
            text-shadow: 0 3px 10px rgba(0,0,0,0.3);
        }
        
        /* PRODUCT CONTENT AREA */
        .product-content {
            padding: 25px;
        }
        
        /* SECTION INSIDE CARD */
        .card-section { 
            background: rgba(255,255,255,0.95);
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 15px;
        }
        
        .card-section:last-child {
            margin-bottom: 0;
        }
        
        .section-title { 
            font-size: 16px; 
            font-weight: 800; 
            color: #119247; 
            margin-bottom: 12px; 
            text-transform: uppercase; 
            letter-spacing: 1px;
            border-bottom: 3px solid #f5c800;
            padding-bottom: 8px;
        }
        
        /* SIZES & PRICES LIST */
        .size-list { 
            list-style: none; 
            padding: 0;
        }
        
        .size-item { 
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            padding: 10px 12px; 
            margin-bottom: 8px; 
            background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
            border: 2px solid #e0e0e0;
            border-radius: 10px; 
            transition: all 0.3s;
        }
        
        .size-item:hover { 
            border-color: #119247; 
            background: #e8f5ee;
            transform: translateX(8px);
            box-shadow: 0 4px 15px rgba(17,146,71,0.2);
        }
        
        .size-item:last-child {
            margin-bottom: 0;
        }
        
        .size-name { 
            font-weight: 700; 
            color: #333; 
            font-size: 14px;
        }
        
        .size-price { 
            font-weight: 900; 
            color: #e8401c; 
            font-size: 15px;
            background: #fff3e0;
            padding: 4px 12px;
            border-radius: 15px;
        }
        
        /* FLAVORS GRID */
        .flavor-grid { 
            display: grid; 
            grid-template-columns: repeat(2, 1fr); 
            gap: 10px;
        }
        
        .flavor-tag { 
            background: linear-gradient(135deg, #f5c800 0%, #ffd700 100%);
            color: #333; 
            padding: 10px 15px; 
            border-radius: 20px; 
            text-align: center; 
            font-weight: 700; 
            font-size: 13px;
            box-shadow: 0 4px 12px rgba(245,200,0,0.3);
            transition: all 0.3s;
            border: 2px solid transparent;
        }
        
        .flavor-tag:hover { 
            transform: scale(1.08);
            box-shadow: 0 6px 20px rgba(245,200,0,0.5);
            border-color: #119247;
        }
        
        /* FOOTER */
        .footer {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            text-align: center;
            padding: 40px;
            margin-top: 50px;
            border-top: 5px solid #f5c800;
        }
        
        .footer-links {
            margin-bottom: 20px;
        }
        
        .footer-links a {
            color: #f5c800;
            text-decoration: none;
            margin: 0 15px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .footer-links a:hover {
            color: white;
        }
        
        .footer-copy {
            font-size: 14px;
            color: #ccc;
            margin-top: 15px;
        }
        
        /* RESPONSIVE */
        @media (max-width: 1400px) {
            .product-grid { 
                grid-template-columns: repeat(2, 1fr); 
            }
        }
        
        @media (max-width: 900px) {
            .product-grid { 
                grid-template-columns: 1fr; 
            }
            
            .hero h1 { 
                font-size: 42px; 
            }
        }
        
        @media (max-width: 600px) {
            .navbar { 
                flex-direction: column; 
                gap: 20px; 
            }
            
            .flavor-grid { 
                grid-template-columns: 1fr; 
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
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
        
        <!-- HERO BANNER - COMPACT -->
        <div class="hero">
            <div class="hero-content">
                <div class="hero-banner">
                    <h1>MENU</h1>
                </div>
            </div>
        </div>
        
        <!-- MAIN MENU CONTAINER -->
        <div class="menu-container">
            <div class="product-grid">
                
                <!-- FRENCH FRIES CARD -->
                <div class="product-card">
                    <div class="product-image">
                        <img src="finalhomepage.jpg" alt="French Fries" />
                    </div>
                    <div class="product-name">French Fries</div>
                    <div class="product-content">
                        <!-- SIZES & PRICES -->
                        <div class="card-section">
                            <div class="section-title">Sizes & Prices</div>
                            <ul class="size-list">
                                <li class="size-item">
                                    <span class="size-name">Regular</span>
                                    <span class="size-price">PHP 39</span>
                                </li>
                                <li class="size-item">
                                    <span class="size-name">Large</span>
                                    <span class="size-price">PHP 58</span>
                                </li>
                                <li class="size-item">
                                    <span class="size-name">Jumbo</span>
                                    <span class="size-price">PHP 97</span>
                                </li>
                                <li class="size-item">
                                    <span class="size-name">Mega</span>
                                    <span class="size-price">PHP 135</span>
                                </li>
                                <li class="size-item">
                                    <span class="size-name">Giga</span>
                                    <span class="size-price">PHP 198</span>
                                </li>
                                <li class="size-item">
                                    <span class="size-name">Terra</span>
                                    <span class="size-price">PHP 228</span>
                                </li>
                            </ul>
                        </div>
                        
                        <!-- FLAVORS -->
                        <div class="card-section">
                            <div class="section-title">Available Flavors</div>
                            <div class="flavor-grid">
                                <div class="flavor-tag">Sour Cream</div>
                                <div class="flavor-tag">BBQ</div>
                                <div class="flavor-tag">Cheese</div>
                                <div class="flavor-tag">Salt</div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- CHICKEN POPS CARD -->
                <div class="product-card">
                    <div class="product-image">
                        <img src="homeimg2.png" alt="Chicken Pops" />
                    </div>
                    <div class="product-name">Chicken Pops</div>
                    <div class="product-content">
                        <!-- SIZES & PRICES -->
                        <div class="card-section">
                            <div class="section-title">Sizes & Prices</div>
                            <ul class="size-list">
                                <li class="size-item">
                                    <span class="size-name">Solo</span>
                                    <span class="size-price">PHP 75</span>
                                </li>
                                <li class="size-item">
                                    <span class="size-name">Large Mix</span>
                                    <span class="size-price">PHP 95</span>
                                </li>
                                <li class="size-item">
                                    <span class="size-name">Mega Mix</span>
                                    <span class="size-price">PHP 199</span>
                                </li>
                            </ul>
                        </div>
                        
                        <!-- FLAVORS -->
                        <div class="card-section">
                            <div class="section-title">Available Flavors</div>
                            <div class="flavor-grid">
                                <div class="flavor-tag">Sour Cream</div>
                                <div class="flavor-tag">BBQ</div>
                                <div class="flavor-tag">Cheese</div>
                                <div class="flavor-tag">Salt</div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- LOOPYS CARD -->
                <div class="product-card">
                    <div class="product-image">
                        <img src="homepageimg.jpg" alt="Loopys" />
                    </div>
                    <div class="product-name">Loopys</div>
                    <div class="product-content">
                        <!-- SIZES & PRICES -->
                        <div class="card-section">
                            <div class="section-title">Sizes & Prices</div>
                            <ul class="size-list">
                                <li class="size-item">
                                    <span class="size-name">Large</span>
                                    <span class="size-price">PHP 75</span>
                                </li>
                                <li class="size-item">
                                    <span class="size-name">Mega</span>
                                    <span class="size-price">PHP 135</span>
                                </li>
                            </ul>
                        </div>
                        
                        <!-- FLAVORS -->
                        <div class="card-section">
                            <div class="section-title">Available Flavors</div>
                            <div class="flavor-grid">
                                <div class="flavor-tag">Sour Cream</div>
                                <div class="flavor-tag">BBQ</div>
                                <div class="flavor-tag">Cheese</div>
                                <div class="flavor-tag">Salt</div>
                            </div>
                        </div>
                    </div>
                </div>
                
            </div>
        </div>
        
        <!-- FOOTER -->
        <div class="footer">
            <div class="footer-links">
                <a href="#">Terms & Conditions</a> |
                <a href="#">Privacy Policy</a>
            </div>
            <div class="footer-copy">© 2026 Potato Corner. All rights reserved.</div>
        </div>
    </form>
</body>
</html>
