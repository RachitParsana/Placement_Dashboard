<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="Dashboard.aspx.cs"
    Inherits="Placement_Dashboard.Dashboard" %>

<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <title>Placement Management System</title>

    <link href="Content/site.css" rel="stylesheet" />
</head>

<body>

<form id="form1" runat="server">

<div class="layout">

    <!-- SIDEBAR -->

    <aside class="sidebar">

        <div class="brand">
            <div class="brand-icon">🎓</div>

            <div>
                <h2>Placement Cell</h2>
                <span>Marwadi University</span>
            </div>
        </div>

        <nav class="navigation">

            <a href="Dashboard.aspx" class="nav-item active">
                <span>▦</span> Dashboard
            </a>

            <a href="#studentRecords" class="nav-item">
                <span>♟</span> Student Records
            </a>

            <a href="Companies.aspx" class="nav-item">
                <span>▥</span> Company Analytics
            </a>

            <a href="PlacementReport.aspx" class="nav-item">
                <span>▤</span> Crystal Reports
            </a>

        </nav>

        <div class="sidebar-footer">
            Connecting Students<br />
            To Better Opportunities
        </div>

    </aside>


    <!-- MAIN CONTENT -->

    <main class="main-content">

        <!-- HEADER -->

        <header class="page-header">

            <div>
                <p class="welcome">WELCOME TO PLACEMENT MANAGEMENT SYSTEM</p>

                <h1>Placement <span>Dashboard</span></h1>

                <p class="subtitle">
                    Monitor student placements and recruitment performance.
                </p>
            </div>

            <div class="header-actions">
                <a href="PlacementReport.aspx" class="report-button">
                    View Crystal Report →
                </a>
            </div>

        </header>


        <!-- MESSAGE -->

        <asp:Label ID="lblMessage"
            runat="server"
            CssClass="message"
            Visible="false">
        </asp:Label>


        <!-- STATISTICS -->

        <section class="stats-grid">

            <div class="stat-card blue-card">
                <span class="stat-icon">♟</span>
                <p>Total Students</p>
                <h2><asp:Label ID="lblTotal" runat="server" Text="0" /></h2>
                <small>Students enrolled</small>
            </div>

            <div class="stat-card green-card">
                <span class="stat-icon">✓</span>
                <p>Placed Students</p>
                <h2><asp:Label ID="lblPlaced" runat="server" Text="0" /></h2>
                <small>Successfully placed</small>
            </div>

            <div class="stat-card red-card">
                <span class="stat-icon">×</span>
                <p>Unplaced Students</p>
                <h2><asp:Label ID="lblUnplaced" runat="server" Text="0" /></h2>
                <small>Seeking opportunities</small>
            </div>

            <div class="stat-card yellow-card">
                <span class="stat-icon">%</span>
                <p>Placement Rate</p>
                <h2><asp:Label ID="lblPercentage" runat="server" Text="0%" /></h2>
                <small>Placed students / total</small>
            </div>

            <div class="stat-card purple-card">
                <span class="stat-icon">★</span>
                <p>Highest Package</p>
                <h2><asp:Label ID="lblHighestPackage" runat="server" Text="0 LPA" /></h2>
                <small>Top package offered</small>
            </div>

            <div class="stat-card cyan-card">
                <span class="stat-icon">▥</span>
                <p>Average Package</p>
                <h2><asp:Label ID="lblAveragePackage" runat="server" Text="0 LPA" /></h2>
                <small>Average of placed students</small>
            </div>

        </section>


        <!-- FILTER SECTION -->

        <section class="panel filter-panel">

            <div class="section-title">
                <span class="section-icon">⌕</span>

                <div>
                    <h2>Find Student Records</h2>
                    <p>Apply filters to locate placement information.</p>
                </div>
            </div>

            <div class="filter-grid">

                <div class="filter-group">

                    <label>Placement Status</label>

                    <asp:DropDownList
                        ID="ddlStatus"
                        runat="server"
                        CssClass="form-control"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="FilterChanged">

                        <asp:ListItem Text="All Statuses" Value="-1" />
                        <asp:ListItem Text="Placed" Value="1" />
                        <asp:ListItem Text="Not Placed" Value="0" />

                    </asp:DropDownList>

                </div>


                <div class="filter-group">

                    <label>Company</label>

                    <asp:DropDownList
                        ID="ddlCompany"
                        runat="server"
                        CssClass="form-control"
                        AutoPostBack="true"
                        OnSelectedIndexChanged="FilterChanged">

                        <asp:ListItem Text="All Companies" Value="ALL" />

                    </asp:DropDownList>

                </div>


                <div class="filter-group search-group">

                    <label>Search Student</label>

                    <div class="search-box">

                        <asp:TextBox
                            ID="txtSearch"
                            runat="server"
                            CssClass="form-control"
                            placeholder="Enter name or enrollment number..." />

                        <asp:Button
                            ID="btnSearch"
                            runat="server"
                            Text="Search"
                            CssClass="btn-primary"
                            OnClick="btnSearch_Click" />

                        <asp:Button
                            ID="btnReset"
                            runat="server"
                            Text="Reset"
                            CssClass="btn-reset"
                            OnClick="btnReset_Click" />

                    </div>

                </div>

            </div>

        </section>


        <!-- STUDENT DETAILS -->

        <asp:Panel
            ID="pnlDetails"
            runat="server"
            Visible="false"
            CssClass="panel details-panel">

            <div class="section-title">
                <span class="section-icon">♙</span>

                <div>
                    <h2>Student Placement Profile</h2>
                    <p>Detailed information of the selected student.</p>
                </div>

                <asp:Button
                    ID="btnCloseDetails"
                    runat="server"
                    Text="Close"
                    CssClass="btn-reset"
                    OnClick="btnCloseDetails_Click" />

            </div>

            <asp:DetailsView
                ID="dvStudentDetails"
                runat="server"
                AutoGenerateRows="true"
                CssClass="details-table"
                GridLines="None">
            </asp:DetailsView>

        </asp:Panel>


        <!-- GRIDVIEW -->

        <section class="panel records-panel" id="studentRecords">

            <div class="records-heading">

                <div>
                    <span class="eyebrow">DATA CONTROL 1</span>
                    <h2>Student Placement Records</h2>
                    <p>Student information and recruitment details.</p>
                </div>

                <span class="control-badge">GRIDVIEW</span>

            </div>


            <div class="table-wrapper">

                <asp:GridView
                    ID="gvStudents"
                    runat="server"
                    AutoGenerateColumns="False"
                    DataKeyNames="StudentId"
                    CssClass="data-grid"
                    GridLines="None"
                    EmptyDataText="No student records found."
                    OnSelectedIndexChanged="gvStudents_SelectedIndexChanged">

                    <Columns>

                        <asp:BoundField
                            DataField="StudentId"
                            HeaderText="ID" />

                        <asp:BoundField
                            DataField="EnrollmentNo"
                            HeaderText="Enrollment No" />

                        <asp:BoundField
                            DataField="StudentName"
                            HeaderText="Student Name" />

                        <asp:BoundField
                            DataField="Department"
                            HeaderText="Department" />

                        <asp:BoundField
                            DataField="PassingYear"
                            HeaderText="Batch" />

                        <asp:TemplateField HeaderText="Status">

                            <ItemTemplate>

                                <span class='<%# Convert.ToBoolean(Eval("IsPlaced")) ? "status placed" : "status unplaced" %>'>

                                    <%# Convert.ToBoolean(Eval("IsPlaced")) ? "Placed" : "Not Placed" %>

                                </span>

                            </ItemTemplate>

                        </asp:TemplateField>

                        <asp:BoundField
                            DataField="CompanyName"
                            HeaderText="Company" />

                        <asp:BoundField
                            DataField="JobRole"
                            HeaderText="Job Role" />

                        <asp:TemplateField HeaderText="Package (LPA)">

                            <ItemTemplate>

                                <%# Eval("PackageLPA") == DBNull.Value ? "—" : String.Format("{0:N2}", Eval("PackageLPA")) %>

                            </ItemTemplate>

                        </asp:TemplateField>

                        <asp:CommandField
                            ShowSelectButton="True"
                            SelectText="View Profile"
                            HeaderText="Action"
                            ButtonType="Link"
                            ControlStyle-CssClass="action-link" />

                    </Columns>

                </asp:GridView>

            </div>

        </section>


        <footer class="footer">
            Placement Management System | ASP.NET Web Forms | Practical 9
        </footer>

    </main>

</div>

</form>

</body>
</html>