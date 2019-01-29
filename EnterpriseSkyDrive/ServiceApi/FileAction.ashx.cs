using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using EnterpriseSkyDrive.Common;
namespace EnterpriseSkyDrive.ServiceApi
{
    /// <summary>
    /// FileAction 的摘要说明
    /// </summary>
    public class FileAction : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.Buffer = true;
            context.Response.ExpiresAbsolute = System.DateTime.Now.AddMilliseconds(0);
            context.Response.Expires = 0;
            context.Response.AddHeader("Pragma", "No-Cache");


            try
            {
                string action = context.Request["action"];

                switch (action)
                {
                    case "LIST":
                        ResponseList(context);
                        break;

                    case "RENAME":
                        RenameFile(context);
                        break;

                    case "DELETE":
                        Delete(context);
                        break;

                    case "NEWDIR":
                        CreateDirectory(context);
                        break;

                    case "NEWFILE":
                        SaveFile(context, true);
                        break;

                    case "UPLOAD":
                        UploadFile(context);
                        break;

                    case "DOWNLOAD":
                        DownFile(context);
                        break;

                    case "GETEDITFILE":
                        GetFileContent(context);
                        break;

                    case "SAVEEDITFILE":
                        SaveFile(context, false);
                        break;

                    case "ZIP":
                        Zip(context);
                        break;
                    case "UNZIP":
                        UnZip(context);
                        break;

                    case "CUT":
                        CutCopy(context, true);
                        break;

                    case "COPY":
                        CutCopy(context, false);
                        break;

                    case "DOWNLOADTOZIP":
                        Download(context);
                        break;
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("ERROR:" + ex.Message + "," + ex.InnerException);
            }
        }

        private void GetFileContent(HttpContext context)
        {
            string path = context.Server.MapPath(context.Request["value1"]);

            context.Response.Write(File.ReadAllText(path, Encoding.UTF8));
        }

        private void ResponseList(HttpContext context)
        {
            string value1 = context.Request["value1"];
            StringBuilder json = new StringBuilder("var GetList = {\"Directory\":[", 200);
            string path = context.Server.MapPath(value1);

            string[] dir = Directory.GetDirectories(path);
            string[] file = Directory.GetFiles(path);

            foreach (string d in dir)
            {
                DirectoryInfo info = new DirectoryInfo(d);
                json.Append("{\"Name\":\"" + info.Name + "\",\"LastModify\":\"" + info.LastWriteTime + "\"},");
            }

            string temp = json.ToString();
            if (temp.EndsWith(","))
            {
                temp = temp.Substring(0, temp.Length - 1);
            }

            json = new StringBuilder(temp);

            json.Append("],\"File\":[");

            foreach (string f in file)
            {
                FileInfo info = new FileInfo(f);
                string size = null;

                if (info.Length > 1024 * 1024)
                {
                    size = ((double)info.Length / 1024 / 1024).ToString("F2") + "MB";
                }
                else if (info.Length > 1024)
                {
                    size = ((double)info.Length / 1024).ToString("F2") + "KB";
                }
                else
                {
                    size = info.Length.ToString() + "B";
                }

                json.Append("{\"Name\":\"" + info.Name + "\",\"Size\":\"" + size + "\",\"LastModify\":\"" + info.LastWriteTime + "\"},");
            }

            temp = json.ToString();

            if (temp.EndsWith(","))
            {
                temp = temp.Substring(0, temp.Length - 1);
            }

            json = new StringBuilder(temp);
            json.Append("]}");

            context.Response.Write(json.ToString());
        }

        private void RenameFile(HttpContext context)
        {
            string oldName = context.Server.MapPath(context.Request["value1"]);
            string newName = context.Server.MapPath(context.Request["value2"]);

            MoveFile(oldName, newName);

            context.Response.Write("OK");
        }

        private void MoveFile(string oldName, string newName)
        {
            File.Move(oldName, newName);
        }

        private void CreateDirectory(HttpContext context)
        {
            string path = context.Request["value1"];

            Directory.CreateDirectory(context.Server.MapPath(path));

            context.Response.Write("OK");
        }

        private void Delete(HttpContext context)
        {
            string[] members = context.Request["value1"].Split('|');

            foreach (string path in members)
            {
                string p = context.Server.MapPath(path);

                if (File.Exists(p))
                {
                    File.Delete(p);
                }
                else if (Directory.Exists(p))
                {
                    Directory.Delete(p, false);
                }
            }

            context.Response.Write("OK");
        }

        private void SaveFile(HttpContext context, bool newFile)
        {
            string path = context.Server.MapPath(context.Request["value1"]);

            if (newFile && File.Exists(path))
            {
                context.Response.Write("EXISTS");
                return;
            }

            string content = context.Request["content"];

            StreamWriter sw = File.CreateText(path);
            sw.Write(content);
            sw.Close();

            context.Response.Write("OK");
        }

        private void UploadFile(HttpContext context)
        {
            string path = context.Server.MapPath(context.Request["value1"]);
            HttpFileCollection files = context.Request.Files;

            long allSize = 0;

            for (int i = 0; i < files.Count; i++)
            {
                allSize += files[i].ContentLength;
            }

            if (allSize > 20 * 1024 * 1024)
            {
                context.Response.Write("文件大小超出限制!");
            }

            for (int i = 0; i < files.Count; i++)
            {
                files[i].SaveAs(path + Path.GetFileName(files[i].FileName));
            }

            context.Response.Write("OK");
        }

        private void DownFile(HttpContext context)
        {
            string fileString = context.Request["value1"];
            string[] files = fileString.Split('|');

            foreach (string file in files)
            {
                string path = context.Server.MapPath(file);

                if (File.Exists(path))
                {
                    DownloadFileHelper.ResponseFile(path, context);
                }
            }
        }

        private void Download(HttpContext context)
        {
            string zipFile = context.Server.MapPath("~/#download.zip");
            string[] fd = context.Request["value1"].Split('|');
            List<string> files = new List<string>();
            List<string> dir = new List<string>();

            foreach (string file in fd)
            {
                string f = context.Server.MapPath(file);

                if (File.Exists(f))
                {
                    files.Add(f);
                }
                else if (Directory.Exists(f))
                {
                    dir.Add(f);
                }
            }

            ZipHelper.Zip(Path.GetDirectoryName(zipFile) + "\\", zipFile, "", true, files.ToArray(), dir.ToArray());
            DownloadFileHelper.ResponseFile(zipFile, "down_" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".zip", context);
        }

        private void Zip(HttpContext context)
        {
            string zipFile = context.Server.MapPath(context.Request["value1"]);
            string[] fd = context.Request["value2"].Split('|');
            List<string> files = new List<string>();
            List<string> dir = new List<string>();

            foreach (string file in fd)
            {
                string f = context.Server.MapPath(file);

                if (File.Exists(f))
                {
                    files.Add(f);
                }
                else if (Directory.Exists(f))
                {
                    dir.Add(f);
                }
            }

            ZipHelper.Zip(Path.GetDirectoryName(zipFile) + "\\", zipFile, "", true, files.ToArray(), dir.ToArray());

            context.Response.Write("OK");
        }

        private void UnZip(HttpContext context)
        {
            string unZipDir = context.Server.MapPath(context.Request["value1"]);
            string[] zipFiles = context.Request["value2"].Split('|');

            foreach (string file in zipFiles)
            {
                ZipHelper.UnZip(context.Server.MapPath(file), unZipDir, "");
            }

            context.Response.Write("OK");
        }

        private void CutCopy(HttpContext context, bool move)
        {
            string destPath = context.Server.MapPath(context.Request["value1"]);
            string[] files = context.Request["value2"].Split('|');

            foreach (string file in files)
            {
                string path = context.Server.MapPath(file);
                string fileName = Path.GetFileName(path);

                if (File.Exists(path))
                {
                    if (move)
                    {
                        File.Move(path, destPath + fileName);
                    }
                    else
                    {
                        File.Copy(path, destPath + fileName);
                    }
                }
                else if (Directory.Exists(path))
                {
                    if (move)
                    {
                        Directory.Move(path, destPath + fileName);
                    }
                    else
                    {
                        CopyDirectory(path, destPath + fileName);
                    }
                }
            }

            context.Response.Write("OK");
        }

        private void CopyDirectory(string SourceDirectory, string TargetDirectory)
        {
            if (TargetDirectory.StartsWith(SourceDirectory, StringComparison.CurrentCultureIgnoreCase))
            {
                throw new Exception("");
            }

            DirectoryInfo source = new DirectoryInfo(SourceDirectory);
            DirectoryInfo target = new DirectoryInfo(TargetDirectory);

            if (!source.Exists)
            {
                return;
            }

            if (!target.Exists)
            {
                target.Create();
            }

            FileInfo[] sourceFiles = source.GetFiles();

            for (int i = 0; i < sourceFiles.Length; i++)
            {
                File.Copy(sourceFiles[i].FullName, target.FullName + "\\" + sourceFiles[i].Name, true);
            }

            DirectoryInfo[] sourceDirectories = source.GetDirectories();

            for (int j = 0; j < sourceDirectories.Length; j++)
            {
                CopyDirectory(sourceDirectories[j].FullName, target.FullName + "\\" + sourceDirectories[j].Name);
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}