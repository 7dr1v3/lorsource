<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"%>
<%@ page import="java.net.URLEncoder,java.sql.Connection,java.sql.ResultSet, java.sql.Statement, java.util.Date"   buffer="20kb" %>
<%@ page import="java.util.List"%>
<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="ru.org.linux.boxlet.BoxletVectorRunner" %>
<%@ page import="ru.org.linux.site.*" %>
<%@ page import="ru.org.linux.util.ProfileHashtable" %>
<%@ page import="ru.org.linux.util.StringUtil" %>
<% Template tmpl = Template.getTemplate(request); %>
<jsp:include page="WEB-INF/jsp/head.jsp"/>

        <title>��������� �������</title>
<jsp:include page="WEB-INF/jsp/header.jsp"/>

  <table class=nav><tr>
    <td align=left valign=middle>
      ��������� �������
    </td>

    <td align=right valign=middle>
      [<a style="text-decoration: none" href="addphoto.jsp">�������� ����������</a>]
      [<a style="text-decoration: none" href="register.jsp?mode=change">��������� �����������</a>]
      [<a style="text-decoration: none" href="rules.jsp">������� ������</a>]
     </td>
    </tr>
 </table>

<h1>��������� �������</h1>

<%
   if (request.getParameter("mode")==null) {
	if (tmpl.isUsingDefaultProfile())
		out.print("������������ ������� �� ���������");
	else
		out.print("������������ �������: <i>" + tmpl.getProfileName()+"</i>");

%>
<%
  if (!Template.isSessionAuthorized(session)) {
%>

<h2>������� �...</h2>
<ol>
<li>������� �������� ��������� ��������� ����������� ����� � �������� � ���
�� �������
<li>��������� ������� ������������� � ��������������� ������ ������������
(���� �� ��� �� ������������������ � ��� �� ����� - ��� <a href="register.jsp">����</a>).
<li>���������� � ������� ������� ������������ � Cookie, ��� ����� ��������
��� �������������� �� ������ ����������� ���� ������� ��� ������ �������������.
<li>������������ ��� ������� ����� ����� ���������� �����, �� �������������� ���
������ ������ ��.
</ol>

<h2>���������� �������</h2>
����������� ������� ��� ����� �������������� ��� ������� ������ (������������)
�������:
<form method=POST action="edit-profile.jsp">
<input type=hidden name=mode value=setup>
�������:
<input type=text name=profile><br>
��� nick ��������� � ������ ���������� �������?
<input type=checkbox name=setnick><br>
<input type=submit value="Setup/����������">
</form>
<%
  }
%>

<h2>��������� �������</h2>
<% ProfileHashtable profHash=tmpl.getProf(); %>
<form method=POST action="edit-profile.jsp">
<input type=hidden name=mode value=set>
<table>
<tr><td colspan=2><hr></td></tr>
<tr><td>���������� ����������</td>
<td><input type=checkbox name=photos <%= profHash.getBooleanPropertyHTML("photos")%>></td></tr>
<tr><td>����� ��� ������ �� ��������</td>
<td><input type=text name=topics value=<%= profHash.getInt("topics")%>></td></tr>
<tr><td>����� ������������ �� ��������</td>
<td><input type=text name=messages value=<%= profHash.getInt("messages")%>></td></tr>
<tr><td>����� ����� � ������</td>
<td><input type=text name=tags value=<%= profHash.getInt("tags")%>></td></tr>
<tr><td>������� ������� �������� � 3 �������</td>
<td><input type=checkbox name=3column <%= profHash.getBooleanPropertyHTML("main.3columns")%>></td></tr>
<tr><td>���������� ���������� � ����������� ����� ������� ���������� ���������</td>
<td><input type=checkbox name=showinfo <%= profHash.getBooleanPropertyHTML("showinfo")%>></td></tr>
<tr><td>���������� ��������� �����������</td>
<td><input type=checkbox name=showanonymous <%= profHash.getBooleanPropertyHTML("showanonymous")%>></td></tr>
<tr><td>��������� ������� � �������� ��������� (tr:hover)</td>
<td><input type=checkbox name=hover <%= profHash.getBooleanPropertyHTML("hover")%>></td></tr>  
  <tr><td colspan=2><hr></td></tr>
<tr>
  <td valign=top>����</td>
  <td>
    <% String style=tmpl.getStyle(); %>
    <input type=radio name=style value=white <%= "white".equals(style)?"checked":"" %>> White (old)<br>
    <input type=radio name=style value=black <%= "black".equals(style)?"checked":"" %>> Black (default)<br>
    <input type=radio name=style value=white2 <%= "white2".equals(style)?"checked":"" %>> White2<br>
  </td>
</tr>
  <tr><td colspan=2><hr></td></tr>
<tr>
  <td valign=top>�������������� �� ���������</td>
  <td>
    <% String formatMode=tmpl.getFormatMode(); %>
    <input type=radio name=format_mode value=ntobrq <%= "ntobrq".equals(formatMode)?"checked":"" %>> User line break w/quoting<br>
    <input type=radio name=format_mode value=quot   <%= "quot".equals(formatMode)?"checked":"" %>> TeX paragraphs w/quoting (default)<br>
    <input type=radio name=format_mode value=tex    <%= "tex".equals(formatMode)?"checked":"" %>> TeX paragraphs w/o quoting<br>
    <input type=radio name=format_mode value=ntobr  <%= "ntobr".equals(formatMode)?"checked":"" %>> User line break w/o quoting<br>
    <input type=radio name=format_mode value=html   <%= "html".equals(formatMode)?"checked":"" %>> Ignore line breaks<br>
    <input type=radio name=format_mode value=pre    <%= "pre".equals(formatMode)?"checked":"" %>> Preformatted text <br>
  </td>
</tr>

<% if (!Template.isSessionAuthorized(session)) { %>

<tr><td colspan=2><hr></td></tr>
<tr><td>������� (��� ������������)</td><td>
<input type=text name=profile value=""></td></tr>
<tr><td>������</td><td>
<input type=password name=password></td></tr>
<% } %>

</table>

<input type=submit value="Setup/����������">
</form>

<h2>��������� ������� ��������</h2>
����� ����, ��� �� ������� ���� ����������� �������, �� ������
��������� ��� ���� ���������� ��������� ��������.
<ul>
<li><a href="edit-boxes.jsp">��������� ��������� ��������</a>
</ul>

<h2>��������� ���������� ���������</h2>
<ul>
<li><a href="ignore-list.jsp">��������� ���������� ���������</a>
</ul>

<%
  } else if ("setup".equals(request.getParameter("mode"))) {
    if (request.getParameter("profile")==null) {
      throw new UserErrorException("�������� profile �� ������");
    }

    String name = StringUtil.getFileName(request.getParameter("profile"));
    if (name.length()!=0 && !Template.isAnonymousProfile(name)) {
      throw new UserErrorException("������ ������� �� ����� ���� ������");
    }

    out.print("������ �������: " + name);

    response.setHeader("Location", tmpl.getMainUrl());
    response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);

    Cookie prof = new Cookie("profile", name);
    if (name.length()==0) {
      prof.setMaxAge(0);
    } else {
      prof.setMaxAge(60 * 60 * 24 * 31 * 12);
    }

    prof.setPath("/");
    response.addCookie(prof);
  } else if ("set".equals(request.getParameter("mode"))) {
    String profile;

    if (!Template.isSessionAuthorized(session)) {
      throw new AccessViolationException("Not authorized");
    } else {
      profile = (String) session.getAttribute("nick");
    }

    int topics = Integer.parseInt(request.getParameter("topics"));
    int messages = Integer.parseInt(request.getParameter("messages"));
    int tags = Integer.parseInt(request.getParameter("tags"));

    if (topics <= 0 || topics > 1000)
      throw new BadInputException("������������ ����� ���");
    if (messages <= 0 || messages > 1000)
      throw new BadInputException("������������ ����� ���������");
    if (tags<=0 || tags>100)
      throw new BadInputException("������������ ����� ����� � ������");

    if (tmpl.getProf().setInt("topics", topics)) ;
    out.print("���������� �������� <i>topics</i><br>");
    if (tmpl.getProf().setInt("messages", messages)) ;
    out.print("���������� �������� <i>messages</i><br>");
    if (tmpl.getProf().setInt("tags", tags)) ;
    out.print("���������� �������� <i>tags</i><br>");
    if (tmpl.getProf().setBoolean("newfirst", request.getParameter("newfirst")))
      out.print("���������� �������� <i>newfirst</i><br>");
    if (tmpl.getProf().setBoolean("photos", request.getParameter("photos")))
      out.print("���������� �������� <i>photos</i><br>");
    if (tmpl.getProf().setBoolean("sortwarning", request.getParameter("sortwarning")))
      out.print("���������� �������� <i>sortwarning</i><br>");
    if (tmpl.getProf().setString("format.mode", request.getParameter("format_mode")))
      out.print("���������� �������� <i>format.mode</i><br>");
    if (tmpl.getProf().setString("style", request.getParameter("style")))
      out.print("���������� �������� <i>style</i><br>");
    if (tmpl.getProf().setBoolean("main.3columns", request.getParameter("3column")))
      out.print("���������� �������� <i>main.3columns</i><br>");
    if (tmpl.getProf().setBoolean("showinfo", request.getParameter("showinfo")))
      out.print("���������� �������� <i>showinfo</i><br>");
    if (tmpl.getProf().setBoolean("showanonymous", request.getParameter("showanonymous")))
      out.print("���������� �������� <i>showanonymous</i><br>");
    if (tmpl.getProf().setBoolean("hover", request.getParameter("hover")))
      out.print("���������� �������� <i>hover</i><br>");

    tmpl.writeProfile(profile);

    Cookie prof = new Cookie("profile", profile);
    prof.setMaxAge(60 * 60 * 24 * 31 * 12);
    prof.setPath("/");
    response.addCookie(prof);

    response.setHeader("Location", tmpl.getMainUrl());
    response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);

    out.print("Ok");
  }
%>
<p><b>��������!</b> ��������� �� ��������� ��� ���������� ��������� �����
�� ������������. ����������� ������ <i>Reload</i> ������ ��������.

  <jsp:include page="WEB-INF/jsp/footer.jsp"/>
