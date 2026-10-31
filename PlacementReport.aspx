<%@ Page Language="C#" AutoEventWireup="true"
CodeBehind="PlacementReport.aspx.cs"
Inherits="Placement_Dashboard.PlacementReportPage" %>

<%@ Register Assembly="CrystalDecisions.Web"
Namespace="CrystalDecisions.Web"
TagPrefix="CR" %>

<!DOCTYPE html>

<html>
<head runat="server">

<title>Student Placement Report</title>

<style>
    body {
        margin: 0;
        padding: 25px;
        font-family: Arial, sans-serif;
        background: #f2f7f8;
    }

    .container {
        background: white;
        padding: 25px;
        border-radius: 12px;
        border: 1px solid #dce8e9;
    }

    h2 {
        color: #064e4b;
        text-align: center;
    }

    .back-button {
        display: inline-block;
        background: #087d70;
        color: white;
        text-decoration: none;
        padding: 11px 18px;
        border-radius: 6px;
        margin-bottom: 20px;
    }

    .status {
        display: block;
        margin-bottom: 15px;
        font-weight: bold;
    }

    .report-area {
        width: 100%;
        overflow-x: auto;
    }
</style>

</head>

<body>

<form id="form1" runat="server">

<div class="container">

    <h2>Student Placement Report</h2>

    <a href="Dashboard.aspx" class="back-button">
        ← Back to Dashboard
    </a>

    <asp:Label
        ID="lblStatus"
        runat="server"
        CssClass="status">
    </asp:Label>

    <div class="report-area">

        <CR:CrystalReportViewer
            ID="CrystalReportViewer1"
            runat="server"
            AutoDataBind="false"
            Width="100%"
            Height="700px" />

    </div>

</div>

</form>

</body>
</html>
