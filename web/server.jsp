<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="java.net.URLEncoder" errorPage="/error.jsp"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="ru.org.linux.site.Template" %>
<% Template tmpl = new Template(request, config, response); %>
<%= tmpl.head() %>
<title>� �������</title>
<%= tmpl.DocumentHeader() %>
<div class=text>

<h1>� �������</h1>
�������������� ������ <i>LINUX.ORG.RU: ������� ���������� �� �� Linux</i> ��� 
������� � ������� 
1998 ����. ����� ����� �������� �������� ��������� ��������������� ������� � 
������������ ������� Linux � ������. �� ��������� ���������� �����������
������ ��������� Linux-��������������� �����������, ���������� ���������,
��������, ������������� � ������� ���������.

<h1>���� ��������</h1>
�� ������ ������������ ��� ������ ��� ������ �� ��� ����:<br>
<img width=88 height=31 src="/img/button.gif">
  <p>
  � ���� ������:<br>
  <img src="/img/linux-banner5.gif" alt="www.linux.org.ru" width="468" height="60"> 
  </p>

<h1>�������</h1>
���������� ������� � ����������� � ���� �������� �������������� ��������� 
��� "<a href="http://www.ratel.ru">����-��������</a>".
<p>
	���������� ������� ����� ���������� ���: <a href="http://linuxhacker.ru/stats">����������</a>.

<h1>����</h1>
  <p>
�� �������� ��:
    <ul>
      <li>Fedora 7</li>
      <li>���� PostgreSQL 8.2</li>
      <li>Apache2 2.0</li>
      <li>Sun Java SDK 1.5</li>
      <li>Caucho Resin 2.1</li>
      <li>memcached 1.2</li>
    </ul>
      ������� ����� ������� (<b>green</b>) ��
�����������������.
  </p>

<h1>���� �������</h1>
������ ���������� � ����������� ������������� � ��������� ����� �������. 
<ul>
<li><a href="whois.jsp?nick=maxcom">������ ���������</a> (maxcom) - <i>�����������
�������</i> -
����������, ���������, ������, �������, �������������� ����������.

<li><a href="whois.jsp?nick=green">���� ������</a> (green) - ����������������� �������, ������

<%
  Connection db = null;

  try {
    db = tmpl.getConnection("server");

    Statement st = db.createStatement();
    ResultSet rs = st.executeQuery("SELECT nick, name FROM users WHERE canmod ORDER BY id");

    while (rs.next()) {
      String nick = rs.getString("nick");
      String name = rs.getString("name");

      if (nick.equals("maxcom")) {
        continue;    
      }

      out.print("<li><a href=\"whois.jsp?nick="+URLEncoder.encode(nick)+"\">"+name+"</a> ("+nick+")");  
    }
%>

</ul>

  <%
  } finally {
    if (db!=null) {
      db.close();
    }
  }
  %>
</div>

<h1>������� �� �����</h1>
Linux.org.ru �������������� ������, �� �� ���������� ����������� ������� �� ���������� �����
����� ��������, ������������ ��� ������ �����. �� ������ ���������� ������� ����� Google Adsense
�� ���������� ������ ����� �� ������ "<a href="https://adwords.google.com/select/OnsiteSignupLandingPage?client=ca-pub-6069094673001350&referringUrl=http://www.linux.org.ru/">���������� ������� �� ���� �����</a>".

<h1>��������� �������</h1>
<ul>
  <li><a href="http://www.lorquotes.ru/">LorQuotes</a> - ��������� ������</li>
  <li><a href="http://www.lastfm.ru/group/Linux-org-ru">������ linux.org.ru �� last.fm</a></li>
  <li><a href="http://community.livejournal.com/l_o_r/">������ l.o.r.</a></li>
</ul>

<%= tmpl.DocumentFooter() %>
