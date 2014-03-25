<%@ WebHandler Language="C#" Class="edit" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using System.Xml;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;

public class edit : IHttpHandler
{
    public string dayName = DateTime.Now.AddDays(1).ToString("yyMMdd");
    public Encoding code = Encoding.GetEncoding("utf-8");
    public int groupCount;
    public void ProcessRequest(HttpContext context)
    {
        context.Request.ContentEncoding = Encoding.GetEncoding("utf-8");
        context.Response.ContentEncoding = Encoding.GetEncoding("utf-8");
        string file = context.Request.Form["file"];
        string paras = context.Server.UrlDecode(context.Request.Form["paras"]);
        string cmd = context.Request.Form["cmd"];
        string path = "/subject/" + file + "/";
        string strIdentify = "";
        try
        {
            switch (cmd)
            {
                case "creatFile":
                    creatFile(context, path);
                    break;
                case "creatPage":
                    creatPage(context, path);
                    break;
                default:
                    context.Response.Write("False");
                    break;
            }
        }
        catch (ArgumentException ex)
        {
            context.Response.Write(ex);
        }
    }
    private void creatFile(HttpContext context, string path)
    {
        //生成文件夹
        string FileFullPath = "/subject/" + dayName + "_news/";
        string FullNamePath = context.Server.MapPath(FileFullPath);
        string imagesPath = FullNamePath + "photo/";
        string rawPath = FullNamePath + "raw/";
        string datas = FullNamePath + "datas/";
        if (creatFile(FullNamePath))
        {
            creatFile(imagesPath);
            creatFile(rawPath);
            creatFile(datas);
        }
        context.Response.Write("True");
    }
    private void creatPage(HttpContext context, string path)
    {
        groupCount = Int32.Parse(context.Request.Form["groupCount"]);
        string groupHTML = "";
        string fullPath = context.Server.MapPath(path + "/");
        XElement root = null;
        try
        {
            root = XDocument.Load(fullPath + "datas/page.config.xml").Root;
        }
        catch
        {
            context.Response.Write("配置文档不存在！");
        }
        if (root!=null)
        {
            try
            {
                //打开tpl模板文本流
                string str = null;
                str = ReadStream(context.Server.MapPath("/subject/edit/newspaper/tpl/index.tpl"), code);
                string repeaterStrCont = "";
                string repeaterStr = ReadStream(context.Server.MapPath("/subject/edit/newspaper/tpl/repeater.tpl"), code);
                string rootAttribute = root.Attribute("title").Value;
                str = str.Replace("{$date}", ((rootAttribute == "每周旅游快报") ? "" : (path.Substring(11, 2) + "月" + path.Substring(13, 2) + "日")) + rootAttribute);
                int count = 0;
                XElement groupElement;
                for (int i = 0; i < groupCount; i++)
                {
                    groupElement = root.Elements().ElementAt(i);
                    groupHTML += "<div style=\"width:639px; height:37px; background:url(http://www.gzl.com.cn/subject/NewsData/120305newspaper/area_bg.jpg) no-repeat; margin:0px auto;\"> <span style=\"font:20px/32px '微软雅黑', '黑体'; color:#fff; padding-left:20px;\">" + groupElement.Attribute("type").Value + "</span></div>";
                    for (int j = 0; j < groupElement.Elements().Count(); j++)
                    {
                        count++;
                        repeaterStrCont = repeaterStr;
                        repeaterStrCont = repeaterStrCont.Replace("{$title}", groupElement.Elements().ElementAt(j).Value).Replace("{$photoName}", path + "photo/news_" + count.ToString() + "_b.jpg").Replace("{$photoIndex}", path +"photo"+ count.ToString());
                        groupHTML += repeaterStrCont;
                    }
                    groupHTML += "<div> <span style=\"width:639px; height:21px; background:url(http://www.gzl.com.cn/subject/NewsData/120305newspaper/break_line.jpg) no-repeat; margin:0px auto; overflow:hidden; display:block;\"></span> </div>";
                }
                str = str.Replace("{$newsRepeater}", groupHTML);
                //保存，生成网页
                CreatWebPage(fullPath + "index.htm", str);
                repeaterStr = "";
                repeaterStrCont = "";
            }
            catch (Exception ex)
            {
                context.Response.Write(ex);
            }
            try
            {
                //生成缩略图与查看器网页
                DirectoryInfo folder = new DirectoryInfo(fullPath);
                FileInfo[] raw_file = folder.GetFiles("raw/*.jpg");
                System.Drawing.Image image = null;
                Bitmap bmp = new Bitmap(616, 235);
                //从Bitmap创建一个System.Drawing.Graphics对象，用来绘制高质量的缩小图。
                System.Drawing.Graphics gr = System.Drawing.Graphics.FromImage(bmp);
                //设置 System.Drawing.Graphics对象的SmoothingMode属性为HighQuality
                gr.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
                //下面这个也设成高质量
                gr.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighQuality;
                //下面这个设成High
                gr.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.High;
                System.Drawing.Rectangle rectDestination = new System.Drawing.Rectangle(0, 0, 616, 235);
                if (raw_file.Length != 0)
                {
                    string viewer = ReadStream(context.Server.MapPath("/subject/edit/newspaper/tpl/photo.tpl"), code);
                    string viewerCont = "";
                    string num;
                    foreach (FileInfo DeletFile in new DirectoryInfo(fullPath).GetFiles("photo/*.jpg"))
                    {
                        File.Delete(DeletFile.FullName);
                    }
                    foreach (FileInfo file in raw_file)
                    {
                        num = file.Name.Substring(0, 1);
                        image = System.Drawing.Image.FromFile(file.FullName);
                        gr.DrawImage(GetThumbNailImage(image, 616, 235), rectDestination, 0, 0, 616, 235, GraphicsUnit.Pixel);
                        bmp.Save(fullPath + "photo/news_" + num + "_b.jpg");
                        viewerCont = viewer;
                        viewerCont = viewerCont.Replace("{$photoIndex}", file.Name);
                        CreatWebPage(fullPath + "photo" + num + ".htm", viewerCont);
                    }
                    gr.Dispose();
                    bmp.Dispose();
                    image.Dispose();
                    context.Response.Write("True");
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("图片生成失败！详情"+ex);
            }
        }
        else {
            context.Response.Write("\"raw\"文件夹为空！");
        }
    }

    private bool creatFile(string fileName)
    {
        if (!Directory.Exists(fileName))
        {
            Directory.CreateDirectory(fileName);
            return true;
        }
        else { return false; }
    }
    private bool coypFiles(string sourcePath, string targetPath)
    {
        string destFile;
        if (Directory.Exists(targetPath))
        {
            string[] files = Directory.GetFiles(sourcePath);
            foreach (string s in files)
            {
                destFile = Path.Combine(targetPath, Path.GetFileName(s));
                File.Copy(s, destFile, true);
            }
            return true;
        }
        else { return false; }
    }
    private string ReadStream(string path, Encoding code)
    {
        string str = null;
        StreamReader sr = null;
        string file = new FileInfo(path).FullName;
        try
        {
            sr = new StreamReader(file, code);
            str = sr.ReadToEnd();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            sr.Close();
        }
        return str;
    }
    private void CreatWebPage(string name, string contain)
    {
        //保存，生成网页
        StreamWriter sw = null;
        try
        {
            sw = new StreamWriter(name, false, code);
            sw.Write(contain);
            sw.Flush();
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            contain = "";
            sw.Close();
        }
    }
    public static System.Drawing.Image GetThumbNailImage(System.Drawing.Image originalImage, int newWidth, int newHeight)
    {
        System.Drawing.Image newImage = originalImage;
        Graphics graphics = null;
        if ((double)originalImage.Width / 2.62 > (double)originalImage.Height)
        {
            newWidth = Convert.ToInt32(Math.Round(((double)newHeight / (double)originalImage.Height) * (double)originalImage.Width));
        }
        else {
            newHeight = Convert.ToInt32(Math.Round(((double)newWidth / (double)originalImage.Width) * (double)originalImage.Height));
        }
        try
        {
            newImage = new Bitmap(newWidth, newHeight);
            graphics = Graphics.FromImage(newImage);

            graphics.CompositingQuality = CompositingQuality.HighQuality;
            graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
            graphics.SmoothingMode = SmoothingMode.HighQuality;

            graphics.Clear(Color.Transparent);

            graphics.DrawImage(originalImage, new Rectangle(0, 0, newWidth, newHeight), new Rectangle(0, 0, originalImage.Width, originalImage.Height), GraphicsUnit.Pixel);
        }
        catch { }
        finally
        {
            if (graphics != null)
            {
                graphics.Dispose();
                originalImage.Dispose();
                graphics = null;
            }
        }

        return newImage;
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}