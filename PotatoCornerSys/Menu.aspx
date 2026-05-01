<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Menu.aspx.cs" Inherits="PotatoCornerSys.Menu" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Potato Corner - Menu</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        :root {
            --green-dark:  #0d7336;
            --green:       #119247;
            --yellow:      #f5c800;
            --yellow-lite: #ffd700;
            --red:         #e8401c;
            --red-lite:    #ff6b47;
            --bg:          #e8e8e8;
            --white:       #ffffff;
            --text-dark:   #1a2a1a;
            --text-mid:    #333;
        }

        html, body {
            width: 100%; height: 100%;
            overflow: hidden;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg);
        }

        .shell {
            display: flex;
            flex-direction: column;
            height: 100vh;
            min-height: 0;
        }

        .navbar {
            flex: 0 0 auto;
            background: linear-gradient(135deg, var(--green) 0%, var(--green-dark) 100%);
            padding: 15px 50px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 5px solid var(--yellow);
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
            z-index: 100;
        }

        .navbar-logo img {
            height: 85px;
            filter: drop-shadow(0 2px 6px rgba(0,0,0,0.2));
            transition: transform 0.3s;
        }
        .navbar-logo img:hover { transform: scale(1.06); }

        .navbar-links {
            display: flex;
            align-items: center;
            gap: 36px;
            list-style: none;
        }

        .navbar-links a {
            color: var(--white);
            text-decoration: none;
            font-size: 15px;
            font-weight: 700;
            letter-spacing: 0.4px;
            transition: color 0.2s, transform 0.2s;
            position: relative;
        }
        .navbar-links a:hover { color: var(--yellow); transform: translateY(-2px); }
        .navbar-links a::after {
            content: '';
            position: absolute;
            bottom: -4px; left: 0;
            width: 0; height: 2px;
            background: var(--yellow);
            transition: width 0.3s;
        }
        .navbar-links a:hover::after { width: 100%; }

        .hero {
            flex: 0 0 auto;
            padding: 12px 40px;
            text-align: center;
            background: var(--bg);
        }

        .hero-content {
            max-width: 860px;
            margin: 0 auto;
        }

        .hero-banner {
            background: linear-gradient(135deg, var(--red) 0%, var(--red-lite) 100%);
            padding: 7px 32px;
            border-radius: 20px;
            box-shadow: 0 6px 24px rgba(232,64,28,0.28);
        }

        .hero-banner h1 {
            font-size: 24px;
            color: var(--white);
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 4px;
            text-shadow: 0 2px 8px rgba(0,0,0,0.25);
        }

        .menu-container {
            flex: 1 1 0;
            min-height: 0;
            padding: 14px 36px;
            background: var(--bg);
        }

        .product-grid {
            display: flex;
            height: 100%;
            gap: 20px;
            min-height: 0;
        }

        .product-card {
            flex: 1 1 0;
            min-width: 0;
            background: linear-gradient(160deg, var(--green) 0%, var(--green-dark) 100%);
            border-radius: 22px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            box-shadow: 0 12px 40px rgba(0,0,0,0.22);
            transition: transform 0.35s, box-shadow 0.35s;
        }

        .product-card:hover {
            transform: translateY(-6px) scale(1.015);
            box-shadow: 0 20px 56px rgba(0,0,0,0.3);
        }

        .product-image {
            flex: 0 0 auto;
            background: linear-gradient(135deg, var(--green) 0%, var(--green-dark) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 10px;
            position: relative;
        }

        .product-image::after {
            content: '';
            position: absolute;
            bottom: 0; left: 0;
            width: 100%; height: 3px;
            background: linear-gradient(90deg, var(--yellow), var(--yellow-lite));
        }

        .product-image img {
            height: 100px;
            width: 100%;
            object-fit: contain;
            filter: drop-shadow(0 6px 16px rgba(0,0,0,0.18));
            transition: transform 0.3s;
        }
        .product-card:hover .product-image img { transform: scale(1.08) rotate(1.5deg); }

        .product-name {
            flex: 0 0 auto;
            font-size: clamp(14px, 1.6vw, 22px);
            color: var(--yellow);
            font-weight: 900;
            text-transform: uppercase;
            text-align: center;
            padding: 8px 12px 4px;
            letter-spacing: 2px;
            text-shadow: 0 2px 8px rgba(0,0,0,0.28);
        }

        .product-content {
            flex: 1 1 0;
            min-height: 0;
            overflow-y: auto;
            padding: 6px 10px 10px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            scrollbar-width: thin;
            scrollbar-color: rgba(255,255,255,0.3) transparent;
        }

        .card-section {
            background: rgba(255,255,255,0.95);
            border-radius: 12px;
            padding: 10px 12px;
            flex-shrink: 0;
        }

        .section-title {
            font-size: 11px;
            font-weight: 800;
            color: var(--green);
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            border-bottom: 2px solid var(--yellow);
            padding-bottom: 5px;
        }

        .size-list { list-style: none; display: flex; flex-direction: column; gap: 5px; }

        .size-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 6px 10px;
            background: #f8f9fa;
            border: 1.5px solid #e0e0e0;
            border-radius: 8px;
            transition: border-color 0.2s, background 0.2s, transform 0.2s;
        }
        .size-item:hover {
            border-color: var(--green);
            background: #e8f5ee;
            transform: translateX(4px);
        }

        .size-name  { font-weight: 700; color: var(--text-mid); font-size: 12px; }
        .size-price { font-weight: 900; color: var(--red); font-size: 12px; background: #fff3e0; padding: 2px 9px; border-radius: 10px; }

        .flavor-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 6px;
        }

        .flavor-tag {
            background: linear-gradient(135deg, var(--yellow), var(--yellow-lite));
            color: var(--text-dark);
            padding: 7px 8px;
            border-radius: 14px;
            text-align: center;
            font-weight: 700;
            font-size: 11px;
            box-shadow: 0 3px 8px rgba(245,200,0,0.28);
            transition: transform 0.2s, box-shadow 0.2s;
            border: 1.5px solid transparent;
        }
        .flavor-tag:hover { transform: scale(1.07); border-color: var(--green); }

        .footer {
            flex: 0 0 auto;
            background: linear-gradient(135deg, var(--green) 0%, var(--green-dark) 100%);
            color: var(--white);
            text-align: center;
            padding: 10px;
            border-top: 5px solid var(--yellow);
        }

        .footer-links { margin-bottom: 6px; }
        .footer-links a {
            color: var(--yellow);
            text-decoration: none;
            margin: 0 10px;
            font-weight: 600;
            font-size: 14px;
        }
        .footer-links a:hover { color: var(--white); }
        .footer-copy { font-size: 14px; color: #ccc; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="shell">

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

    <div class="hero">
        <div class="hero-content">
            <div class="hero-banner">
                <h1>MENU</h1>
            </div>
        </div>
    </div>

    <div class="menu-container">
        <div class="product-grid">

            <!-- FRENCH FRIES -->
            <div class="product-card">
                <div class="product-image">
                    <img src="finalhomepage.jpg" alt="French Fries" />
                </div>
                <div class="product-name">French Fries</div>
                <div class="product-content">
                    <div class="card-section">
                        <div class="section-title">Sizes &amp; Prices</div>
                        <ul class="size-list">
                            <li class="size-item"><span class="size-name">Regular</span><span class="size-price">PHP 39</span></li>
                            <li class="size-item"><span class="size-name">Large</span><span class="size-price">PHP 58</span></li>
                            <li class="size-item"><span class="size-name">Jumbo</span><span class="size-price">PHP 97</span></li>
                            <li class="size-item"><span class="size-name">Mega</span><span class="size-price">PHP 135</span></li>
                            <li class="size-item"><span class="size-name">Giga</span><span class="size-price">PHP 198</span></li>
                            <li class="size-item"><span class="size-name">Terra</span><span class="size-price">PHP 228</span></li>
                        </ul>
                    </div>
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

            <!-- CHICKEN POPS -->
            <div class="product-card">
                <div class="product-image">
                    <img src="homeimg2.png" alt="Chicken Pops" />
                </div>
                <div class="product-name">Chicken Pops</div>
                <div class="product-content">
                    <div class="card-section">
                        <div class="section-title">Sizes &amp; Prices</div>
                        <ul class="size-list">
                            <li class="size-item"><span class="size-name">Solo</span><span class="size-price">PHP 75</span></li>
                            <li class="size-item"><span class="size-name">Large Mix</span><span class="size-price">PHP 95</span></li>
                            <li class="size-item"><span class="size-name">Mega Mix</span><span class="size-price">PHP 199</span></li>
                        </ul>
                    </div>
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

            <!-- LOOPYS -->
            <div class="product-card">
                <div class="product-image">
                    <img src="homepageimg.jpg" alt="Loopys" />
                </div>
                <div class="product-name">Loopys</div>
                <div class="product-content">
                    <div class="card-section">
                        <div class="section-title">Sizes &amp; Prices</div>
                        <ul class="size-list">
                            <li class="size-item"><span class="size-name">Large</span><span class="size-price">PHP 75</span></li>
                            <li class="size-item"><span class="size-name">Mega</span><span class="size-price">PHP 135</span></li>
                        </ul>
                    </div>
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

    <div class="footer">
        <div class="footer-links">
            <a href="#">Terms &amp; Conditions</a> |
            <a href="#">Privacy Policy</a>
        </div>
        <div class="footer-copy">&copy; 2026 Potato Corner. All rights reserved.</div>
    </div>

</div>
</form>
</body>
</html>