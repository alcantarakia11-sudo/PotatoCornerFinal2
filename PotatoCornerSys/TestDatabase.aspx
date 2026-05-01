<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TestDatabase.aspx.cs" Inherits="PotatoCornerSys.TestDatabase" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Database Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .result { background: #f0f0f0; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .error { background: #ffebee; color: #c62828; }
        .success { background: #e8f5e8; color: #2e7d32; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <h1>Database Connection Test</h1>
        <asp:Button ID="btnTest" runat="server" Text="Test Database" OnClick="btnTest_Click" />
        <br /><br />
        <asp:Literal ID="litResults" runat="server"></asp:Literal>
    </form>
</body>
</html>