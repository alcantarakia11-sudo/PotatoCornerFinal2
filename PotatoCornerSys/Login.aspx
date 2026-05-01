<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="PotatoCornerSys.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
        <title>Potato Corner - Login</title>
    <style type="text/css">
        body {
            background-color: #119247;
            text-align: center;
            padding-top: 50px;
            margin: 0;
        }

        .logo {
            width: 280px;
            height: auto;
            margin-bottom: 40px;
            display: block;
            margin-left: auto;
            margin-right: auto;
        }

        .login-container {
            background-color: rgba(255, 255, 255, 0.12);
            width: 420px;
            margin: 0 auto;
            padding: 50px 50px 40px 50px;
            border-radius: 10px;
        }

        .field-group {
            margin-bottom: 28px;
        }

        .textbox {
            display: block;
            margin: 0 auto;
            padding: 14px 16px;
            width: 100%;
            font-size: 17px;
            border-radius: 5px;
            border: none;
            box-sizing: border-box;
        }

        .login-btn {
            background-color: #0F5229;
            color: white;
            padding: 15px 0;
            width: 100%;
            border: none;
            font-size: 17px;
            cursor: pointer;
            margin-top: 36px;
            display: block;
            border-radius: 5px;
            box-sizing: border-box;
        }

        .login-btn:hover {
            background-color: #0a3d1e;
        }

        .error-msg {
            color: #ffcccc;
            margin-top: 16px;
            font-size: 14px;
        }

        .register-link {
            color: white;
            margin-top: 24px;
            font-size: 15px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~/logopotcor.png" CssClass="logo" />

        <div class="login-container">
            <div class="field-group">
                <asp:TextBox ID="txtUsername" runat="server" placeholder="Username" CssClass="textbox"></asp:TextBox>
            </div>
            <div class="field-group">
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Password" CssClass="textbox"></asp:TextBox>
            </div>
            <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="login-btn" OnClick="btnLogin_Click" />
            <asp:Label ID="lblError" runat="server" CssClass="error-msg" Visible="false"></asp:Label>
            <div class="register-link">
                <asp:LinkButton ID="lnkRegister" runat="server" Text="Register here" OnClick="lnkRegister_Click" ForeColor="White"></asp:LinkButton>
            </div>
        </div>
    </form>
</body>
</html>
