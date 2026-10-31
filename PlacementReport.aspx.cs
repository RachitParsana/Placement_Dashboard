using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using CrystalDecisions.CrystalReports.Engine;

namespace Placement_Dashboard
{
    public partial class PlacementReportPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                ReportDocument report =
                Session["PlacementReport"] as ReportDocument;

            if (!IsPostBack || report == null)
                {
                    if (report != null)
                    {
                        report.Close();
                        report.Dispose();
                    }

                    report = LoadReport();

                    Session["PlacementReport"] = report;
                }

                CrystalReportViewer1.ReportSource = report;
                CrystalReportViewer1.DataBind();

                lblStatus.Text = "Report loaded successfully.";
                lblStatus.ForeColor =
                    System.Drawing.Color.Green;
            }
            catch (Exception ex)
            {
                lblStatus.Text =
                    "REPORT ERROR: " + Server.HtmlEncode(ex.Message);

                lblStatus.ForeColor =
                    System.Drawing.Color.Red;
            }
        }

        private ReportDocument LoadReport()
        {
            string cs = ConfigurationManager
                .ConnectionStrings["PlacementDB"].ConnectionString;

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
                P.CompanyName,
                P.JobRole,
                P.PackageLPA
            FROM Students S
            LEFT JOIN Placements P
                ON S.StudentId = P.StudentId
            ORDER BY S.StudentId";

            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlDataAdapter da =
                    new SqlDataAdapter(query, con);

                da.Fill(dt);
            }

            if (dt.Rows.Count == 0)
            {
                throw new Exception(
                    "SQL query returned zero student records."
                );
            }

            ReportDocument report = new ReportDocument();

            report.Load(
                Server.MapPath("~/PlacementReport.rpt")
            );

            report.SetDataSource(dt);

            lblStatus.Text =
                "Database connected. Records received: "
                + dt.Rows.Count;

            return report;
        }
    }

}
