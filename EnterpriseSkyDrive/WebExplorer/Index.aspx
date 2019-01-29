<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="EnterpriseSkyDrive.WebExplorer.Index" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>企业网盘</title>
    <link href="/static/css/ZxjayWebExplorer.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/static/js/ZxjayAjax.js"></script>
    <script type="text/javascript" src="/static/js/ZxjayTree.js"></script>
    <script type="text/javascript" src="/static/js/ZxjayDialog.js"></script>
    <script type="text/javascript" src="/static/js/ZxjayCommon.js"></script>
    <link href="/static/images/zxjaydialog/ZxjayDialog.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/static/js/ueditor/editor_config.js"></script>
    <script type="text/javascript" src="/static/js/ueditor/editor_all_min.js"></script>
    <link rel="stylesheet" href="/static/js/ueditor/themes/default/ueditor.css" />
</head>
<body>
    <div id="fileExplorer">
        <div id="tree">
        </div>
        <div id="rightPanel">
            <div id="path">
                当前位置：<span id="pathString"></span>
            </div>
            <hr />
            <div id="menu">
                <div class="menuItem" onclick="javascript:gotoParentDirectory();">
                    <img class="menuItemImg" src="/static/images/up.gif" alt="" />
                    <div class="tipText">
                        向上
                    </div>
                </div>
                <div class="menuItem" onclick="javascrip:goRoot();">
                    <img class="menuItemImg" src="/static/images/home.gif" alt="" />
                    <div class="tipText">
                        根目录
                    </div>
                </div>
                <div class="menuItem" onclick="javascript:refersh()">
                    <img class="menuItemImg" src="/static/images/refersh.gif" alt="" />
                    <div class="tipText">
                        刷新
                    </div>
                </div>
                <div class="menuItem" onclick="javascript:newDirectory();">
                    <img class="menuItemImg" src="/static/images/newfolder.gif" alt="" />
                    <div class="tipText">
                        新目录
                    </div>
                </div>
                <div class="menuItem" onclick="javascript:newFile();">
                    <img class="menuItemImg" src="/static/images/newfile.gif" alt="" />
                    <div class="tipText">
                        新文件
                    </div>
                </div>
                <div class="menuItem" onclick="javascript:del();">
                    <img class="menuItemImg" src="/static/images/delete.gif" alt="" />
                    <div class="tipText">
                        删除
                    </div>
                </div>
                <div class="menuItem" onclick="javascript:cut();">
                    <img class="menuItemImg" src="/static/images/cut.gif" alt="" />
                    <div class="tipText">
                        剪切
                    </div>
                </div>
                <div class="menuItem" onclick="javascript:copy();">
                    <img class="menuItemImg" src="/static/images/copy.gif" alt="" />
                    <div class="tipText">
                        复制
                    </div>
                </div>
                <div class="menuItem" onclick="javascript:paste();">
                    <img class="menuItemImg" src="/static/images/paste.gif" alt="" />
                    <div class="tipText">
                        粘贴
                    </div>
                </div>
                <div class="menuItem" onclick="javascript:zipFile();">
                    <img class="menuItemImg" src="/static/images/zipfile.gif" alt="" />
                    <div class="tipText">
                        压缩
                    </div>
                </div>
                <div class="menuItem" onclick="javascript:unZipFile();">
                    <img class="menuItemImg" src="/static/images/unzip.gif" alt="" />
                    <div class="tipText">
                        解压
                    </div>
                </div>
                <div class="menuItem" onclick="javascript:downLoad();">
                    <img class="menuItemImg" src="/static/images/download.gif" alt="" />
                    <div class="tipText">
                        下载
                    </div>
                </div>
                <div class="menuItem" onclick="javascript:uploadFile();">
                    <img class="menuItemImg" src="/static/images/upload.gif" alt="" />
                    <div class="tipText">
                        上传
                    </div>
                </div>
                <div style="clear: both">
                </div>
            </div>
            <div id="fileListHead">
                <div class="chkColumn">
                    <input type="checkbox" id="checkAll" onclick="javascript: selectAll();" title="全部选中" />
                </div>
                <div class="fileType">
                    类型
                </div>
                <div class="fileName">
                    名称
                </div>
                <div class="fileSize">
                    大小
                </div>
                <div class="lastUpdate">
                    最后更新
                </div>
                <div class="rename">
                    重命名
                </div>
                <div style="clear: both;">
                </div>
            </div>
            <div id="fileList">
            </div>
        </div>
    </div>
    <script src="/static/js/ZxjayWebExplorer.js" type="text/javascript"></script>
    <script src="GetTenant.aspx" type="text/javascript"></script>
</body>
</html>