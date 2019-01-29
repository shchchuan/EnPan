using System;

namespace EnterpriseSkyDrive
{
    public partial class Index : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Redirect("/WebExplorer/");
        }
    }
}