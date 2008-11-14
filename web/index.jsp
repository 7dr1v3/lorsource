<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.Connection,java.sql.ResultSet,java.sql.Statement,java.util.Date,java.util.List, ru.org.linux.boxlet.BoxletVectorRunner"   buffer="60kb"%>
<%@ page import="ru.org.linux.site.*" %>
<%@ page import="ru.org.linux.util.ServletParameterParser" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<% Template tmpl = Template.getTemplate(request); %>
<jsp:include page="WEB-INF/jsp/head.jsp"/>

<title>LINUX.ORG.RU - ������� ���������� �� �� Linux</title>
<META NAME="Keywords" CONTENT="linux ������ ������������ ������� ������������ gnu ���������� ��������� ���������� ����������� ���� unix ����� software free documentation operating system ������� news">
<META NAME="Description" CONTENT="��� � Linux �� ������� �����">
<LINK REL="alternate" TITLE="L.O.R RSS" HREF="section-rss.jsp?section=1" TYPE="application/rss+xml">

<%
  response.setDateHeader("Expires", new Date(new Date().getTime() - 20 * 3600 * 1000).getTime());
  response.setDateHeader("Last-Modified", new Date(new Date().getTime() - 2 * 1000).getTime());

%>
<jsp:include page="WEB-INF/jsp/header-main.jsp"/>
<%
  boolean columns3 = tmpl.getProf().getBoolean("main.3columns");

  Connection db = null;
  try {
%>

<div style="clear: both"></div>
<div class="<%= columns3?"newsblog2":"newsblog"%>">
  <div class="<%= columns3?"newsblog-in2":"newsblog-in"%>">

<h1><a href="view-news.jsp?section=1">�������</a></h1>
<%
  if (tmpl.isModeratorSession()) {
    out.print("<div class=\"nav\"  style=\"border-bottom: none\">");

    if (db==null) {
      db = LorDataSource.getConnection();
    }

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

    db.close(); db=null;
  }

  int offset = 0;
  if (request.getParameter("offset")!=null) {
    offset = new ServletParameterParser(request).getInt("offset");

    if (offset<0) {
	offset = 0;
    }

    if (offset>200) {
      offset=200;
    }
  }

  NewsViewer nv = NewsViewer.getMainpage(tmpl.getConfig(), tmpl.getProf(), offset);

  out.print(ViewerCacher.getViewer(nv, tmpl, false));
%>
<div class="nav">
  <% if (offset<200) { %>
  [<a href="index.jsp?offset=<%=offset+20%>">���������� 20</a>]
  <% } %>
  [<a href="add-section.jsp?section=1">�������� �������</a>]
  [<a href="section-rss.jsp?section=1">RSS</a>]
  <% if (offset>20) { %>
    [<a href="index.jsp?offset=<%= (offset-20) %>">��������� 20</a>]
  <% } else if (offset==20) { %>
  [<a href="index.jsp">c�������� 20</a>]
  <% } %>
</div>
</div>
</div>

<%
  BoxletVectorRunner boxes;

  if (tmpl.getProf().getBoolean("main.3columns")) {
    boxes = new BoxletVectorRunner((List) tmpl.getProf().getObject("main3-1"));
  }
  else {
    boxes = new BoxletVectorRunner((List) tmpl.getProf().getObject("main2"));
  }
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
  if (db==null) {
    db = LorDataSource.getConnection();
  }
  
  User user = User.getUser(db, (String) session.getAttribute("nick"));

  out.print("<br>(������: " + user.getStatus() + ')');
%><br>
<input type=submit value="�����"><p>
</form>
* <a href="rules.jsp">�������</a><br>
* <a href="edit-profile.jsp">���������</a><br>&nbsp;<br>
* <a href="show-topics.jsp?nick=<%= user.getNick() %>">��� ����</a><br>
* <a href="show-comments.jsp?nick=<%= user.getNick() %>">��� �����������</a><br>
<% } %>

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

<% } finally {
    if (db!=null) {
      db.close();
    }
  }
%>
<jsp:include page="WEB-INF/jsp/footer-main.jsp"/>
