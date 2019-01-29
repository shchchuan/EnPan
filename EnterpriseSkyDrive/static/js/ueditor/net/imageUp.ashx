<%@ WebHandler Language="C#" Class="imageUp" %>

using System;
using System.Web;
using System.IO;
using System.Net;
using System.Text;

public class imageUp : IHttpHandler{
    public void ProcessRequest(HttpContext context){

        String title = String.Empty;
        String oriName = String.Empty;

        //文件上传状态,初始默认成功，可选参数{"SUCCESS","ERROR","SIZE","TYPE"}
        string state = "SUCCESS";

        HttpPostedFile imgFile = context.Request.Files[0];
        string ext = Path.GetExtension(imgFile.FileName).ToLower();
        if(".gif;.png;.jpg;.jpeg;.bmp".IndexOf(ext)<0)
        {
            state = "文件格式不支持，仅能上传图片文件";
        }
        string path = string.Empty;
        if (state == "SUCCESS")
        {
            Stream stream = imgFile.InputStream;
            byte[] binaryData = new Byte[stream.Length];
            stream.Read(binaryData, 0, (imgFile.ContentLength));
            imgFile.InputStream.Close();

            string postData = Convert.ToBase64String(binaryData, 0, binaryData.Length);

            string size = context.Request.QueryString["size"];

            path = GetResponseFileUrl(ext, postData);
        }

        //获取图片描述
        if (context.Request.Form["pictitle"] != null){
            if (!String.IsNullOrEmpty(context.Request.Form["pictitle"])){
                title = context.Request.Form["pictitle"];
            }
        }
        //获取原始文件名
        if (context.Request.Form["fileName"] != null)
        {
            if (!String.IsNullOrEmpty(context.Request.Form["fileName"]))
            {
                oriName = context.Request.Form["fileName"].Split(',')[1];
            }
        }

        //向浏览器返回数据json数据
        context.Response.ContentType = "text/plain";
        context.Response.Write(string.Format("{{'url' : '{0}', 'title' : '{1}', 'original':'{2}', 'state':'{3}'}}",path, title,oriName, state));
    }

    public bool IsReusable{
        get{
            return false;
        }
    }


    /// <summary>
    /// 获取上传后的图片URL
    /// </summary>
    /// <param name="fileExt"></param>
    /// <param name="postData"></param>
    /// <returns></returns>
    public static string GetResponseFileUrl(string fileExt, string postData)
    {
        System.Net.ServicePointManager.Expect100Continue = false;
        return ResponseToString(doPost("http://img.f.etuyu.cn/TaskUpload.ashx", string.Format("ext={0}&data={1}", fileExt, postData.Replace("+", "%2B"))));
    }

    /// <summary>
    /// 根据相应返回字符串
    /// </summary>
    /// <param name="response"></param>
    /// <returns></returns>
    private static string ResponseToString(WebResponse response)
    {
        try
        {
            Encoding encoding = Encoding.Default;
            string ContentType = response.ContentType.Trim();
            if (ContentType.IndexOf("utf-8") != -1)
                encoding = Encoding.UTF8;
            else if (ContentType.IndexOf("utf-7") != -1)
                encoding = Encoding.UTF7;
            else if (ContentType.IndexOf("unicode") != -1)
                encoding = Encoding.Unicode;

            StreamReader stream = new StreamReader(response.GetResponseStream(), encoding);
            string code = stream.ReadToEnd();
            stream.Close();
            response.Close();
            return code;
        }
        catch (Exception ce)
        {
            throw ce;
        }
    }
    /// <summary>
    /// 发送Post类型请求
    /// </summary>
    /// <param name="url">请求地址</param>
    /// <param name="postData">参数</param>
    /// <returns></returns>
    private static WebResponse doPost(string url, string postData)
    {
        try
        {
            byte[] paramByte = Encoding.UTF8.GetBytes(postData); // 转化
            HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(url);
            webRequest.Method = "POST";
            webRequest.ContentType = "application/x-www-form-urlencoded";
            webRequest.Referer = "";
            webRequest.Accept = "application/x-shockwave-flash, image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, application/x-silverlight, */*";
            webRequest.UserAgent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 2.0.50727; CIBA)";
            webRequest.ContentLength = paramByte.Length;
            //webRequest.Timeout = 5000;
            Stream newStream = webRequest.GetRequestStream();
            newStream.Write(paramByte, 0, paramByte.Length);    //写入参数
            newStream.Close();
            return webRequest.GetResponse();
        }
        catch (Exception ce)
        {
            throw ce;
        }
    }
}