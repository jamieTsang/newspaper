<html>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>报纸广告详情查看器</title>
<META HTTP-EQUIV="imagetoolbar" CONTENT="no">
<head>
<style type="text/css">
body { font-family: "Verdana", "Arial", "Helvetica", "sans-serif"; font-size: 12px; line-height: 180%; }
td { font-size: 12px; line-height: 150%; }
</style>
<script src="/subject/edit/newspaper/js/photo_view01.js" type="text/JavaScript" /></script>
<script src="/subject/edit/newspaper/js/photo_view02.js" type="text/JavaScript" /></script>
<style type="text/css">
<!--
td, a { font-size:12px; color:#000000 }
#Layer1 { position:absolute; z-index:100; top: 10px; }
#Layer2 { position:absolute; z-index:1; }
-->
</style>
</head>
<body>
<div id="Layer1">
  <table border="0" cellspacing="2" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
      <td><img src="/subject/edit/newspaper/images/up.gif" width="20" height="20" style="cursor:hand" onClick="clickMove('up')" title="向上"></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td><img src="/subject/edit/newspaper/images/left.gif" width="20" height="20" style="cursor:hand" onClick="clickMove('left')" title="向左"></td>
      <td><img src="/subject/edit/newspaper/images/zoom.gif" width="20" height="20" style="cursor:hand" onClick="realsize();" title="还原"></td>
      <td><img src="/subject/edit/newspaper/images/right.gif" width="20" height="20" style="cursor:hand" onClick="clickMove('right')" title="向右"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><img src="/subject/edit/newspaper/images/down.gif" width="20" height="20" style="cursor:hand" onClick="clickMove('down')" title="向下"></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><img src="/subject/edit/newspaper/images/zoom_in.gif" width="20" height="20" style="cursor:hand" onClick="bigit();" title="放大"></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><img src="/subject/edit/newspaper/images/zoom_out.gif" width="20" height="20" style="cursor:hand" onClick="smallit();" title="缩小"></td>
      <td>&nbsp;</td>
    </tr>
  </table>
</div>
<p><br>
<div id='hiddenPic' style='position:absolute; left:0px; top:0px; width:0px; height:0px; z-index:1; visibility: hidden;'><img name='images2' src='raw/{$photoIndex}' border='0' /></div>
<div id='block1' onmouseout='drag=0' onmouseover='dragObj=block1; drag=1;' style='z-index:10; height: 0; left: 0px; position: absolute; top: 0px; width: 0; cursor:move;' class="dragAble"> <img name='images1' src='raw/{$photoIndex}' border='0' onload="resizeimg(this,this.width,this.height);" /></div>
</body>
</html>