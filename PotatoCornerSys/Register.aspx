<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="PotatoCornerSys.Register" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Potato Corner - Register</title>
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

        .register-container {
            background-color: rgba(255, 255, 255, 0.12);
            width: 420px;
            margin: 0 auto;
            padding: 50px 50px 40px 50px;
            border-radius: 10px;
        }

        .field-group {
            margin-bottom: 22px;
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

        .register-btn {
            background-color: #0F5229;
            color: white;
            padding: 15px 0;
            width: 100%;
            border: none;
            font-size: 17px;
            cursor: pointer;
            margin-top: 30px;
            display: block;
            border-radius: 5px;
            box-sizing: border-box;
        }

        .register-btn:hover {
            background-color: #0a3d1e;
        }

        .login-link {
            color: white;
            margin-top: 24px;
            font-size: 15px;
        }

        .error-msg {
            color: #ffcccc;
            margin-top: 16px;
            font-size: 14px;
        }

        .success-msg {
            color: #ccffcc;
            margin-top: 16px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~/logopotcor.png" CssClass="logo" />

        <div class="register-container">

    <div class="field-group">
        <asp:TextBox ID="txtName" runat="server" CssClass="textbox" placeholder="Full Name"></asp:TextBox>
    </div>

    <div class="field-group">
        <asp:TextBox ID="txtEmail" runat="server" CssClass="textbox" placeholder="Email"></asp:TextBox>
    </div>

    <div class="field-group">
        <asp:TextBox ID="txtUsername" runat="server" CssClass="textbox" placeholder="Username"></asp:TextBox>
    </div>

    <div class="field-group">
        <asp:TextBox ID="txtPhone" runat="server" CssClass="textbox" placeholder="Phone Number"></asp:TextBox>
    </div>

    <div class="field-group">
        <asp:TextBox ID="txtAddress" runat="server" CssClass="textbox" placeholder="Address"></asp:TextBox>
    </div>

    <div class="field-group">
        <asp:TextBox ID="txtPassword" runat="server" CssClass="textbox" TextMode="Password" placeholder="Password"></asp:TextBox>
    </div>

    <div class="field-group">
        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="textbox" TextMode="Password" placeholder="Confirm Password"></asp:TextBox>
    </div>

    <asp:Button ID="btnRegister" runat="server" Text="Register" CssClass="register-btn" OnClick="btnRegister_Click" />

    <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

    <div class="login-link">
        Already have an account?
        <asp:LinkButton ID="LinkButton1" runat="server" Text="Login" OnClick="lnkLogin_Click" ForeColor="White"></asp:LinkButton>
    </div>

</div>
    </form>
</body>
</html>
