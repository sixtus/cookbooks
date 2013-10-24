<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html>

<head>
<meta name="ROBOTS" content="NOINDEX, NOFOLLOW">
<title>nagios @ <%= node[:fqdn] %></title>
<link rel="shortcut icon" href="images/favicon.ico" type="image/ico">
</head>

<frameset cols="180,*">
<frame src="side.php" name="side" frameborder="0">
<frame src="/nagios/cgi-bin/status.cgi?host=all&amp;type=detail&amp;serviceprops=34&amp;servicestatustypes=28" name="main" frameborder="0">
</frameset>

</html>
