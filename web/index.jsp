<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="java.sql.Connection,java.sql.ResultSet,java.sql.Statement,java.util.Date,java.util.List, ru.org.linux.boxlet.BoxletVectorRunner" errorPage="/error.jsp" buffer="60kb"%>
<%@ page import="ru.org.linux.site.NewsViewer"%>
<%@ page import="ru.org.linux.site.Template" %>
<%@ page import="ru.org.linux.site.User" %>
<%@ page import="ru.org.linux.site.ViewerCacher" %>
<% Template tmpl = new Template(request, config, response);
   tmpl.setMainPage(); %>
<%=   tmpl.head() %>
<title>LINUX.ORG.RU - ������� ���������� �� �� Linux</title>
<META NAME="Keywords" CONTENT="linux ������ ������������ ������� ������������ gnu ���������� ��������� ���������� ����������� ���� unix ����� software free documentation operating system ������� news">
<META NAME="Description" CONTENT="��� � Linux �� ������� �����">
<LINK REL="alternate" TITLE="L.O.R RSS" HREF="section-rss.jsp?section=1" TYPE="application/rss+xml">

<%
  response.setDateHeader("Expires", new Date(new Date().getTime() - 20 * 3600 * 1000).getTime());
  response.setDateHeader("Last-Modified", new Date(new Date().getTime() - 2 * 1000).getTime());

%>
<%= tmpl.DocumentHeader() %>
<%
  boolean columns3 = tmpl.getProf().getBoolean("main.3columns");
%>

<div style="clear: both"></div>
<div class="<%= columns3?"newsblog2":"newsblog"%>">
  <div class="<%= columns3?"newsblog-in2":"newsblog-in"%>">

<h1><a href="view-news.jsp?section=1">�������</a></h1>
<%
  if (tmpl.isModeratorSession()) {
    out.print("<div class=\"nav\"  style=\"border-bottom: none\">");

    Connection db = tmpl.getConnection("index");

    Statement st = db.createStatement();
    ResultSet rs = st.executeQuery("select count(*) from topics,groups,sections where section=sections.id AND sections.moderate and topics.groupid=groups.id and not deleted and not topics.moderate AND postdate>(CURRENT_TIMESTAMP-'1 month'::interval)");

    if (rs.next()) {
      int count = rs.getInt("count");

      out.print("[<a style=\"text-decoration: none\" href=\"view-all.jsp\">����������������: " + count + ", ");
    }

    rs.close();

    rs = st.executeQuery("select count(*) from topics,groups where section=1 AND topics.groupid=groups.id and not deleted and not topics.moderate AND postdate>(CURRENT_TIMESTAMP-'1 month'::interval)");

    if (rs.next()) {
      int count = rs.getInt("count");

      out.print(" � ��� ����� ��������: " + count + "</a>]");
    }

    rs.close();

    st.close();

    out.print("</div>");
  }

  NewsViewer nv = NewsViewer.getMainpage(tmpl.getConfig(), tmpl.getProf());

  out.print(ViewerCacher.getViewer(nv, tmpl, false, true));
%>
<div class="nav">
  [<a href="add-section.jsp?section=1">�������� �������</a>]
  [<a href="section-rss.jsp?section=1">RSS</a>]
</div>
</div>
</div>

<%
  BoxletVectorRunner boxes;

  if (tmpl.getProf().getBoolean("main.3columns"))
    boxes = new BoxletVectorRunner((List) tmpl.getProf().getObject("main3-1"));
  else
    boxes = new BoxletVectorRunner((List) tmpl.getProf().getObject("main2"));
%>

<div class=column>
<div class=boxlet>
<h2>���� �� ����</h2>
<% if (!Template.isSessionAuthorized(session)) { %>
<form method=POST action="login.jsp">
���:<br><input type=text name=nick size=15 style="width: 90%"><br>
������:<br><input type=password name=passwd size=15 style="width: 90%"><br>
<input type=submit value="����">
</form>
* <a href="lostpwd.jsp">������ ������?</a><br>
* <a href="rules.jsp">�������</a><br>
* <a href="register.jsp">�����������</a>
<% } else { %>
<form method=POST action="logout.jsp">
�� ����� ��� <b><%= session.getAttribute("nick") %></b>
<%
  Connection db = tmpl.getConnection("index");
  User user = User.getUser(db, (String) session.getAttribute("nick"));

  out.print(" (������: " + user.getStatus() + ')');
%><br>
<input type=submit value="�����"><p>
</form>
* <a href="rules.jsp">�������</a><br>
* <a href="edit-profile.jsp">���������</a><br>&nbsp;<br>
* <a href="show-topics.jsp?nick=<%= user.getNick() %>">��� ����</a><br>
* <a href="show-comments.jsp?nick=<%= user.getNick() %>">��� �����������</a><br>
<% } %>

</div>

<!-- IBM developerWorks -->
<div class="boxlet" id="ibmdw">
<h2>����� ��������� �� IBM developerWorks</h2>
  <iframe src="dw.jsp?height=400&amp;width=155&amp;main=1" width="158" height="400" scrolling="no" frameborder="0"></iframe>
  <br>&nbsp;<br>

  ���������������� ������ �� IBM ��� ������������ � ������� ���������� ��. �������� ������� 1 ��� � ������.
  <form id="data1" method="post" enctype="multipart/form-data" action="http://www-931.ibm.com/bin/subscriptions/esi/subscribe/RURU/10209/">
                       e-mail:<br>
  <input type="text" size="15" name="email" style="width: 90%" value="">
  <br>
  <input alt="subscribe" type="image" name="butSubmit1" value="Subscribe" src="http://www.ibm.com/i/v14/buttons/ru/ru/subscribe.gif">
                      </form>
</div>

<!-- boxes -->
<%

  out.print(boxes.getContent(tmpl.getObjectConfig(), tmpl.getProf()));

%>
</div>
<% if (columns3) { %>
<div class=column2>
<%
  boxes = new BoxletVectorRunner((List) tmpl.getProf().getObject("main3-2"));

  out.print(boxes.getContent(tmpl.getObjectConfig(), tmpl.getProf()));
%>
</div>
<% } %>

<div style="clear: both"></div>

<%
	tmpl.getObjectConfig().SQLclose();
%>
<%=	tmpl.DocumentFooter(false) %>

<div align=center>
<p>
���������� � ��������� - <a href="whois.jsp?nick=maxcom">������ ���������</a> 1998-2007<br>
���������� ������� � ����������� ��� � ���� �������� �������������� ���������
��� "<a href="http://www.ratel.ru">����-��������</a>"<br>
</p>
</div>
</body>
</html>
