using System;
using System.Text;
using EnterpriseSkyDrive.Common;
namespace EnterpriseSkyDrive.WebExplorer
{
    public partial class GetTenant : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            StringBuilder jsString = new StringBuilder();
            jsString.Append("var nd = new ZxjayTreeNode();");
            jsString.Append("nd.container = $(\"tree\");");
            jsString.Append("nd.text = \"企业网盘\";");
            jsString.AppendFormat("nd.path = \"~/{0}/\";",ConfigHelper.FilePath);
            jsString.Append("nd.Show();");
            jsString.Append("currentNode = nd;");
            jsString.Append("currentNode.Refersh();");

            System.Web.HttpContext.Current.Response.Write(jsString.ToString());
        }
    }
}