<%@ WebHandler Language="C#" Class="fileUp_Remote" %>

using System;
using System.Collections.Generic;
using System.Web;
using System.IO;
using System.Collections;
using System.Net;
using System.Text;

public class fileUp_Remote : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string[] filetype = { ".rar", ".doc", ".docx", ".zip", ".pdf", ".txt", ".swf", ".wmv" };    //文件允许格式
        int size = 100;   //文件大小限制,单位MB,同时在web.config里配置环境默认为100MB
        //上传文件
        Hashtable info = new Hashtable();
        Uploader up = new Uploader();
        info = up.upFile(context, filetype, size); //获取上传状态
        context.Response.Write("{'state':'" + info["state"] + "','url':'" + info["url"] + "','fileType':'" + info["currentType"] + "','original':'" + info["originalName"] + "'}"); //向浏览器返回数据json数据
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }
}
/// <summary>
/// UEditor编辑器通用上传类
/// </summary>
public class Uploader
{
    string URL = null;
    string currentType = null;
    string filename = null;
    /// <summary>
    /// 上传文件的主处理方法
    /// </summary>
    /// <param name="cxt"></param>
    /// <param name="filetype"></param>
    /// <param name="size"></param>
    /// <returns></returns>
    public Hashtable upFile(HttpContext cxt, string[] filetype, int size)
    {
        string state = "SUCCESS";
        string originalName = string.Empty;
        try
        {

            HttpPostedFile uploadFile = cxt.Request.Files[0];
            originalName = uploadFile.FileName;
            string ext = Path.GetExtension(uploadFile.FileName).ToLower();
            //格式验证
            if (checkType(filetype,uploadFile))
            {
                state = "不允许的文件类型";
            }
            if (state == "SUCCESS")
            {
                Stream stream = uploadFile.InputStream;
                byte[] binaryData = new Byte[stream.Length];
                stream.Read(binaryData, 0, (uploadFile.ContentLength));
                uploadFile.InputStream.Close();
                string postData = Convert.ToBase64String(binaryData, 0, binaryData.Length);
                URL = GetResponseFileUrl(ext, postData);
            }
        }
        catch (Exception e)
        {
                        state = "未知错误"+e.Message+e.InnerException;
            URL = "";
        }
        Hashtable infoList = new Hashtable();
        infoList.Add("state", state);
        infoList.Add("url", URL);
        if (currentType != null)
            infoList.Add("currentType", currentType);
        if (originalName != null)
            infoList.Add("originalName", originalName);
        return infoList;
    }
    /// <summary>
    /// 文件类型检测
    /// </summary>
    /// <param name="filetype"></param>
    /// <param name="uploadFile"></param>
    /// <returns></returns>
    private bool checkType(string[] filetype, HttpPostedFile uploadFile)
    {
        currentType = getFileExt(uploadFile);
        return Array.IndexOf(filetype, currentType) == -1;
    }
    /// <summary>
    ///  获取文件扩展名
    /// </summary>
    /// <param name="uploadFile"></param>
    /// <returns></returns>
    private string getFileExt(HttpPostedFile uploadFile)
    {
        string[] temp = uploadFile.FileName.Split('.');
        return "." + temp[temp.Length - 1].ToLower();
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
        return ResponseToString(doPost("http://img.f.etuyu.cn/fileUpload.ashx", string.Format("ext={0}&data={1}", fileExt, postData.Replace("+", "%2B"))));
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
            webRequest.Accept = "application/x-shockwave-flash, aplication/zip, application/msword, application/vnd.ms-powerpoint, application/msexcel, application/vnd.ms-powerpoint, application/msword, application/x-silverlight, */*";
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