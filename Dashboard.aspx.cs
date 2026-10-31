using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Placement_Dashboard
{
    public partial class Dashboard : System.Web.UI.Page
    {
        private string cs = ConfigurationManager
            .ConnectionStrings["PlacementDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadSummary();
                LoadCompanies();
                LoadStudents();
            }
        }

        private void LoadSummary()
        {
            string query = @"
                SELECT
                    COUNT(*) AS TotalStudents,

                    COALESCE(SUM(
                        CASE WHEN IsPlaced = 1 THEN 1 ELSE 0 END
                    ), 0) AS PlacedStudents,

                    COALESCE(SUM(
                        CASE WHEN IsPlaced = 0 THEN 1 ELSE 0 END
                    ), 0) AS UnplacedStudents

                FROM Students";

            using (SqlConnection con = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        int total = Convert.ToInt32(dr["TotalStudents"]);
                        int placed = Convert.ToInt32(dr["PlacedStudents"]);
                        int unplaced = Convert.ToInt32(dr["UnplacedStudents"]);

                        lblTotal.Text = total.ToString();
                        lblPlaced.Text = placed.ToString();
                        lblUnplaced.Text = unplaced.ToString();

                        decimal rate = total == 0
                            ? 0
                            : (decimal)placed * 100 / total;

                        lblPercentage.Text = rate.ToString("N2") + "%";
                    }
                }
            }

            string packageQuery = @"
                SELECT
                    COALESCE(MAX(PackageLPA), 0) AS HighestPackage,
                    COALESCE(AVG(PackageLPA), 0) AS AveragePackage
                FROM Placements";

            using (SqlConnection con = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(packageQuery, con))
            {
                con.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        lblHighestPackage.Text =
                            Convert.ToDecimal(dr["HighestPackage"]).ToString("N2")
                            + " LPA";

                        lblAveragePackage.Text =
                            Convert.ToDecimal(dr["AveragePackage"]).ToString("N2")
                            + " LPA";
                    }
                }
            }
        }

        private void LoadCompanies()
        {
            string query = @"
                SELECT DISTINCT CompanyName
                FROM Placements
                ORDER BY CompanyName";

            using (SqlConnection con = new SqlConnection(cs))
            using (SqlDataAdapter da = new SqlDataAdapter(query, con))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlCompany.Items.Clear();

                ddlCompany.Items.Add(
                    new System.Web.UI.WebControls.ListItem(
                        "All Companies", "ALL"
                    )
                );

                foreach (DataRow row in dt.Rows)
                {
                    string company = row["CompanyName"].ToString();

                    ddlCompany.Items.Add(
                        new System.Web.UI.WebControls.ListItem(
                            company, company
                        )
                    );
                }
            }
        }

        private void LoadStudents()
        {
            string query = @"
                SELECT
                    S.StudentId,
                    S.EnrollmentNo,
                    S.StudentName,
                    S.Department,
                    S.PassingYear,
                    S.IsPlaced,
                    CASE
                        WHEN S.IsPlaced = 1 THEN COALESCE(P.CompanyName, 'Not Assigned')
                        ELSE '—'
                    END AS CompanyName,
                    CASE
                        WHEN S.IsPlaced = 1 THEN COALESCE(P.JobRole, 'Not Assigned')
                        ELSE '—'
                    END AS JobRole,
                    P.PackageLPA

                FROM Students S

                LEFT JOIN Placements P
                    ON S.StudentId = P.StudentId

                WHERE 1 = 1";

            int status = Convert.ToInt32(ddlStatus.SelectedValue);

            string company = ddlCompany.SelectedValue;
            string search = txtSearch.Text.Trim();

            if (status != -1)
            {
                query += " AND S.IsPlaced = @Status";
            }

            if (!string.IsNullOrEmpty(company) && company != "ALL")
            {
                query += " AND P.CompanyName = @Company";
            }

            if (!string.IsNullOrEmpty(search))
            {
                query += @"
                    AND (
                        S.StudentName LIKE @Search
                        OR S.EnrollmentNo LIKE @Search
                    )";
            }

            query += " ORDER BY S.StudentId";

            using (SqlConnection con = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                if (status != -1)
                {
                    cmd.Parameters.AddWithValue("@Status", status);
                }

                if (!string.IsNullOrEmpty(company) && company != "ALL")
                {
                    cmd.Parameters.AddWithValue("@Company", company);
                }

                if (!string.IsNullOrEmpty(search))
                {
                    cmd.Parameters.AddWithValue(
                        "@Search", "%" + search + "%"
                    );
                }

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvStudents.DataSource = dt;
                    gvStudents.DataBind();
                }
            }
        }

        protected void FilterChanged(object sender, EventArgs e)
        {
            LoadStudents();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadStudents();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ddlStatus.SelectedValue = "-1";
            ddlCompany.SelectedValue = "ALL";
            txtSearch.Text = "";

            pnlDetails.Visible = false;
            gvStudents.SelectedIndex = -1;

            LoadStudents();
        }

        protected void gvStudents_SelectedIndexChanged(
            object sender, EventArgs e)
        {
            if (gvStudents.SelectedDataKey != null)
            {
                int studentId = Convert.ToInt32(
                    gvStudents.SelectedDataKey.Value
                );

                LoadStudentDetails(studentId);
            }
        }

        private void LoadStudentDetails(int studentId)
        {
            string query = @"
                SELECT
                    S.StudentId,
                    S.EnrollmentNo,
                    S.StudentName,
                    S.Department,
                    S.PassingYear,

                    CASE
                        WHEN S.IsPlaced = 1 THEN 'Placed'
                        ELSE 'Not Placed'
                    END AS PlacementStatus,

                    COALESCE(P.CompanyName, 'Not Assigned') AS CompanyName,
                    COALESCE(P.JobRole, 'Not Assigned') AS JobRole,
                    COALESCE(
                        CAST(P.PackageLPA AS VARCHAR(20)) + ' LPA',
                        'Not Available'
                    ) AS Package

                FROM Students S

                LEFT JOIN Placements P
                    ON S.StudentId = P.StudentId

                WHERE S.StudentId = @StudentId";

            using (SqlConnection con = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    dvStudentDetails.DataSource = dt;
                    dvStudentDetails.DataBind();

                    pnlDetails.Visible = dt.Rows.Count > 0;
                }
            }
        }

        protected void btnCloseDetails_Click(object sender, EventArgs e)
        {
            pnlDetails.Visible = false;
            gvStudents.SelectedIndex = -1;
        }
    }
}