using System;
using System.Collections;
using System.Xml;
using System.IO;
namespace EnterpriseSkyDrive.Common
{
    public class ConfigHelper
    {
        public static readonly string CurrentPath = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
        static object lockobj = new object();
        static ConfigHelper()
        {
            lock (lockobj)
            {
                Hashtable configTable = new Hashtable();
                AddConfigToHash(configTable, System.IO.Path.Combine(CurrentPath, @"configs/config.config"));
                _FilePath = GetConfig(configTable, "FilePath");
            }
        }
        private static void AddConfigToHash(Hashtable configTable, string file)
        {
            FileInfo fi = new FileInfo(file);
            if (fi.Exists)
            {
                try
                {
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.Load(file);
                    foreach (XmlNode node in xmlDoc.DocumentElement.ChildNodes)
                    {
                        if (configTable.Contains(node.Name))
                            configTable[node.Name] = node.InnerText;
                        else
                            configTable.Add(node.Name, node.InnerText);
                    }
                }
                catch
                {
                    throw new Exception("加载" + file + "失败！");
                }
            }
        }

        /// <summary>
        /// 获取某个配置的值
        /// </summary>
        /// <param name="key">需要获取的配置名字</param>
        /// <returns>该配置的值，如果没有找到，返回空字符串</returns>
        private static string GetConfig(Hashtable configTable, string key)
        {
            if (configTable.Contains(key))
                return configTable[key].ToString();
            else
                return string.Empty;
        }
        /// <summary>
        /// 返回数据库名称
        /// </summary>
        /// <param name="i"></param>
        /// <returns></returns>
        public static string RetureDataName(string sqlconnection)
        {
            int Init = sqlconnection.IndexOf("Catalog");
            if (Init == -1)
                return "";
            string contents = sqlconnection.Substring(Init);
            if (contents.IndexOf(";") >= 0)
                contents = contents.Substring(0, contents.IndexOf(";"));
            if (contents.IndexOf("=") >= 0)
                return contents.Split('=')[1];
            else return "";
        }

        private static string _FilePath = string.Empty;
        public static string FilePath
        {
            get { return _FilePath; }
        }
    }
}
