<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="subject_edit_newspaper_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>报纸生成页</title>
    <!-- Our CSS stylesheet file -->
    <link rel="stylesheet" href="styles.css" />
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
    <script>        !window.jQuery && document.write('<script src="/Static/scripts/jquery-1.7.2.min.js"><\/script>');</script>
    <style>
        #loading_unit
        {
            display: none;
            border-radius: 8px;
            box-shadow: 0 0 4px rgba(0, 0, 0, .5),inset 0 0 60.5px rgba(225, 225, 225, .4);
            position: fixed;
            z-index: 9999;
            width: 310px;
            height: auto;
            left: 50%;
            top: 50%;
            margin-left: -155px;
            margin-top: -60px;
            background: white;
            text-align: center;
            font-size: 16px;
        }
        #loading_unit p
        {
            margin: 0;
        }
        #loading_unit h1
        {
            font-size: 16px;
            color: #555;
            font-weight: bold;
            padding: 0;
            margin: 16px 0 5px 0;
            letter-spacing: -.0125em;
            background: none;
        }
        #loading_unit h2
        {
            font-size: 12px;
            color: #555;
            font-weight: 400;
            padding: 0;
            letter-spacing: -.0125em;
        }
        #loading_unit .progressIn
        {
            background: url("/subject/edit/images/loading_bar.gif") center center no-repeat;
            height:11px;
        }
    </style>
</head>
<body>
    <h1>
        报纸生成页<i>(请使用现代浏览器)</i>v1.0.0 更新日期20131128</h1>
    <h2>
        <%=title %></h2>
    <form id="form1" runat="server">
    <div id="dropbox">
        <span id="tips" class="message" runat="server">请按新建文件夹按钮新建<br />
            <i>(编辑明天报纸请直接按"新建文件夹")</i></span>
    </div>
    </form>
    <div class="mid">
        <button id="Setup">
            <%=btnText %></button>
    </div>
    <input id="groupCount" type="hidden" value="<%=groupCount %>" />
    <script type="text/javascript">
        $(function () {
            var $body = $("body");
            var $setup = $("#Setup");
            var htmlWriter = "";
            var inner = "<h1>正在执行操作...</h1><p id='progress' class='progress progressIn'></p><h2>如长时间无响应，请刷新页面重新保存</h2>";
            htmlWriter += "<div id='loading_unit'></div>";
            $body.append(htmlWriter);
            var groupCount = $("#groupCount").val();
            $setup.click(function () {
                var file = getParameter("file");
                var ajaxObj = {};
                var isCreat = true;
                if (Boolean(file) == "") {
                    ajaxObj = { file: null, cmd: "creatFile", groupCount: null };
                    isCreat = true;
                } else {
                    ajaxObj = { file: file, cmd: "creatPage", groupCount: groupCount };
                    isCreat = false;
                }
                $('#loading_unit').fadeIn('normal').html(inner);
                var timeStar = (new Date()).getTime();
                $.ajax({
                    type: "POST",
                    url: "edit.ashx",
                    data: ajaxObj,
                    timeout: 100000,
                    error: function (XMLHttpRequest, strError, strObject) {
                        showFailure(strObject);
                    },
                    success: function (strValue) {
                        if (/True/.test(strValue) && !/False/.test(strValue)) {
                            showSuccess();
                            if (isCreat) {
                                setTimeout("$('#loading_unit').fadeOut(500);redirect();", 2800);
                            } else {
                                setTimeout("$('#loading_unit').fadeOut(500);", 2800);
                                var timeEnd = (new Date()).getTime();
                                $('#tips').html('报纸网页已经生成<br/><i>(用时' + timeRecoder(timeStar, timeEnd) + '秒)</i><br/><a target="_blank" href="/subject/' + file + '/index.htm">请点击这里</a>');
                            }
                        } else {
                            showFailure(strValue);
                        }
                    },
                    complete: function () {
                        showResult();
                        $('#Setup').fadeOut('normal');
                    }
                });
            });
            function getParameter(sProp) {
                var re = new RegExp(sProp + "=([^\&]*)", "i");
                var a = re.exec(document.location.search);
                if (a == null) return null;
                return a[1];
            };
            function showSuccess() {
                $('#loading_unit p').html("<img id='onebit' src='/subject/edit/images/onebit_34.png' />").removeClass("progressIn");
                $('#loading_unit h2').html("操作成功！");
                $('#loading_unit').fadeIn('normal');
            };
            function showFailure(exp) {
                $('#loading_unit p').html("<img id='onebit' src='/subject/edit/images/onebit_33.png' />").removeClass("progressIn");
                $('#loading_unit h2').html("操作失败！详细情况：" + exp);
                $('#loading_unit').fadeIn('normal');
            };
            function showResult() {
                $('#loading_unit h1').text("操作结果");
                //$('#loading_unit .progress').fadeOut(1000);
            }
            function timeRecoder(t1, t2) {
                var time = (t2 - t1) / 1000;
                return time;
            }
        });
        function redirect() {
            var now = new Date();
            now.setTime(now.getTime() + 24 * 60 * 60 * 1000)
            var month = now.getMonth() + 1;
            var date = now.getDate();
            window.location.search = "file=" + now.getFullYear().toString().substr(2, 2) + (month < 10 ? "0" + month.toString() : month.toString()) + (date < 10 ? "0" + date.toString() : date.toString()) + "_news";
        }
    </script>
</body>
</html>
