using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.IO;
using System.Web.UI.WebControls;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using System.Xml;

public partial class subject_edit_newspaper_Default : System.Web.UI.Page
{
    public string strIdentify = null;
    public string path;
    public string fullPath;
    public string dayName = DateTime.Now.AddDays(1).ToString("yyMMdd");
    public string title;
    public XDocument _data = null;
    public XElement root = null;
    public int groupCount = 0;
    public Encoding code = Encoding.GetEncoding("gb2312");
    public string btnText = "新建文件夹";
    protected void Page_Load(object sender, EventArgs e)
    {
        try { strIdentify = Session["isLogin"].ToString(); }
        catch
        {
            if (strIdentify != "identified ")
                Response.Redirect("/subject/edit/LoginFail.html");
        };
        path = System.Web.HttpUtility.UrlDecode(Request["file"]);
        if (path != null)
        {
            btnText = "生成网页";
            path = System.Web.HttpUtility.UrlDecode(Request["file"]);
            fullPath = Server.MapPath("/subject/" + path + "/");
            
            tips.InnerHtml = "请上传报纸图片到目录/subject/" + path + "/raw/下<br /><i>(完成后请刷新页面查看)</i>";
            DirectoryInfo folder = new DirectoryInfo(fullPath);
            FileInfo[] raw_file = null;
            try
            {
                raw_file = folder.GetFiles("raw/*.jpg");
                if (raw_file.Count() > 0)
                {

                    tips.InnerHtml = "";
                    List<string> pattern = new List<string>(3);
                    string namepattern = @"Q_([^\.]+)";
                    string allpattern = @"（*广州日报）*" + "([\u4E00-\u9FA5]+)";
                    pattern.Add(@"（*广州日报）*出境");
                    pattern.Add(@"（*广州日报）*国内");
                    pattern.Add(@"（*广州日报）*省内");
                    int count = 0;
                    
                    if (MatchString(raw_file[0].Name, @"广州日报") != "未命名")
                    {
                        title = "20" + path.Substring(0, 2) + "年" + path.Substring(2, 2) + "月" + path.Substring(4, 2) + "日报纸内容";
                        _data = new XDocument(new XElement("root", new XAttribute("title", "报纸广告"), new XElement("group", new XAttribute("type", "出境游")), new XElement("group", new XAttribute("type", "国内游")), new XElement("group", new XAttribute("type", "周边游"))));
                        root = _data.Elements("root").First();
                        foreach (FileInfo file in raw_file)
                        {
                            for (int i = 0; i < pattern.Count; i++)
                            {
                                if (MatchString(file.Name, pattern[i]) != "未命名")
                                {
                                    root.Elements().ElementAt(i).Add(new XElement("item", MatchString(file.Name, namepattern)));
                                    break;
                                }
                                else if (i == pattern.Count - 1)
                                {
                                    var newName = MatchString(file.Name, allpattern);
                                    root.Add(new XElement("group", new XAttribute("type", newName), new XElement("item", MatchString(file.Name, namepattern))));
                                    pattern.Add(@"（*广州日报）*" + newName);
                                    break;
                                }
                            }
                        }
                    }
                    else if (MatchString(raw_file[0].Name, @"每周旅游快报") != "未命名")
                    {
                        title = "20" + path.Substring(0, 2) + "年" + path.Substring(2, 2) + "月" + path.Substring(4, 2) + "日每周旅游快报内容";
                        _data = new XDocument(new XElement("root", new XAttribute("title", "每周旅游快报")));
                        root = _data.Element("root");
                        root.Add(new XElement("title", "每周旅游快报"));
                        root.Add(new XElement("group", new XAttribute("type", "")));
                        foreach (FileInfo file in raw_file)
                        {
                            root.Element("group").Add(new XElement("item", "每周旅游快报"));
                        }
                    }
                    else
                    {
                        Response.Write("<script>alert('文件名称格式错误，请检查文件名!');window.location = '/subject/edit/newspaper/default.aspx';</script>");
                    }

                    foreach (XElement g in root.Elements())
                    {
                        if (g.Elements().Count() == 0)
                        {
                            g.Remove();
                        }
                    }
                    foreach (XElement g in root.Elements())
                    {
                        if (g.Elements().Count() > 0)
                        {
                            groupCount++;
                            FileInfo fileReName;
                            foreach (XElement item in g.Elements())
                            {
                                if (item.Value != null)
                                {
                                    tips.InnerHtml += g.Attribute("type").Value + ":" + item.Value + "<br>";
                                    count++;
                                    try
                                    {
                                        fileReName = new DirectoryInfo(fullPath).GetFiles("raw/*" + item.Value + "*.jpg")[0];
                                    }
                                    catch
                                    {
                                        string type = "";
                                        switch (g.Attribute("type").Value)
                                        {
                                            case "出境游":
                                                type = "出境";
                                                break;
                                            case "国内游":
                                                type = "国内";
                                                break;
                                            case "周边游":
                                                type = "省内";
                                                break;
                                            default:
                                                type = g.Attribute("type").Value;
                                                break;
                                        }
                                        fileReName = new DirectoryInfo(fullPath).GetFiles("raw/*" + type + "*.jpg")[0];
                                    }
                                    if (!Regex.IsMatch(fileReName.Name.Substring(0, 2), @"\d+_"))
                                        fileReName.MoveTo(fullPath + "raw/" + count + "_" + fileReName.Name);
                                }
                            }
                        }
                    }
                    _data.Save(fullPath + "datas/page.config.xml");//保存。
                    _data = null;
                }
            }
            catch
            {
                Response.Write("<script>alert('文件夹不存在!');window.location = '/subject/edit/newspaper/default.aspx';</script>");
            }
        }
    }
    private string MatchString(string str, string patterns)
    {
        Match item = Regex.Match(str, patterns);
        if (item.Success)
        {
            return Regex.Match(str, patterns).Groups[1].Value;
        }
        else
        {
            return "未命名";
        }
    }
}