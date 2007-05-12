<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="javax.servlet.http.Cookie,javax.servlet.http.HttpServletResponse,ru.org.linux.site.BadInputException, ru.org.linux.site.Template, ru.org.linux.util.ProfileHashtable" errorPage="error.jsp" buffer="20kb" %>
<%@ page import="ru.org.linux.util.StringUtil"%>
<% Template tmpl = new Template(request, config, response); %>
<%= tmpl.head() %>
	<title>��������� �������</title>
<%= tmpl.DocumentHeader() %>
<h1>��������� �������</h1>

<%
   if (request.getParameter("mode")==null) {
	if (tmpl.isUsingDefaultProfile())
		out.print("������������ ������� �� ���������");
	else
		out.print("������������ �������: <i>" + tmpl.getProfileName()+"</i>");

%>
<%
  if (!tmpl.isSessionAuthorized(session)) {
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

<ul>
<li><a href="http://images.linux.org.ru/addphoto.php">�������� ����������</a></li>
<li><a href="register.jsp?mode=change">��������� �����������</a></li>
</ul>

<h2>��������� �������</h2>
<% ProfileHashtable profHash=tmpl.getProf(); %>
<form method=POST action="edit-profile.jsp">
<input type=hidden name=mode value=set>
<table>
<tr><td colspan=2><hr></td></tr>
<tr><td>����� ����������� � ������</td>
<td><input type=checkbox name=newfirst <%= profHash.getBooleanPropertyHTML("newfirst")%>></td></tr>
<tr><td>���������� ����������</td>
<td><input type=checkbox name=photos <%= profHash.getBooleanPropertyHTML("photos")%>></td></tr>
<tr><td>���������� ��������� � ������� ���������� ������������</td>
<td><input type=checkbox name=sortwarning <%= profHash.getBooleanPropertyHTML("sortwarning")%>></td></tr>
<tr><td>����� ��� ������ �� ��������</td>
<td><input type=text name=topics value=<%= profHash.getIntProperty("topics")%>></td></tr>
<tr><td>����� ������������ �� ��������</td>
<td><input type=text name=messages value=<%= profHash.getIntProperty("messages")%>></td></tr>
<tr><td>������� ������� �������� � 3 �������</td>
<td><input type=checkbox name=3column <%= profHash.getBooleanPropertyHTML("main.3columns")%>></td></tr>
<tr><td>���������� ���������� � ����������� ����� ������� ���������� ���������</td>
<td><input type=checkbox name=showinfo <%= profHash.getBooleanPropertyHTML("showinfo")%>></td></tr>
<tr><td>���������� ��������� �����������</td>
<td><input type=checkbox name=showanonymous <%= profHash.getBooleanPropertyHTML("showanonymous")%>></td></tr>
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

<% if (!tmpl.isSessionAuthorized(session)) { %>

<tr><td colspan=2><hr></td></tr>
<tr><td>������� (��� ������������)</td><td>
<input type=text name=profile value="<%= tmpl.getCookie("NickCookie", "")%>"></td></tr>
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
<%
   } else if ("setup".equals(request.getParameter("mode"))) {
	String name=StringUtil.getFileName(request.getParameter("profile"));

   	out.print("������ �������: " + name);

	if (!tmpl.isSearchMode()) {
          if ("".equals(name)) {
            response.setHeader("Location", tmpl.getMainUrl());
            response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);
          } else {
            response.setHeader("Location", tmpl.getRedirectUrl(name));
            response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);
          }
	}

	Cookie prof=new Cookie("profile", name);
	prof.setMaxAge(60*60*24*31*12);
	prof.setPath("/");
	if (!tmpl.isSearchMode())
		response.addCookie(prof);

	if (request.getParameter("setnick")!=null && "on".equals(request.getParameter("setnick"))) {
		Cookie nick=new Cookie("NickCookie", request.getParameter("profile"));
		nick.setMaxAge(60*60*24*31*24);
		nick.setPath("/");
		response.addCookie(nick);
	}
   } else if ("set".equals(request.getParameter("mode"))) {
        final String profile;

        if (!tmpl.isSessionAuthorized(session)) {
          throw new IllegalAccessException("Not authorized");
        } else {
          profile=(String) session.getAttribute("nick");
        }

	int topics=Integer.parseInt(request.getParameter("topics"));
	int messages=Integer.parseInt(request.getParameter("messages"));

	if (topics<=0 || topics>1000)
		throw new BadInputException("������������ ����� ���");
	if (messages<=0 || messages>1000)
		throw new BadInputException("������������ ����� ���������");

   	if (tmpl.getProf().setIntProperty("topics", new Integer(topics)));
		out.print("���������� �������� <i>topics</i><br>");
   	if (tmpl.getProf().setIntProperty("messages", new Integer(messages)));
		out.print("���������� �������� <i>messages</i><br>");
	if (tmpl.getProf().setBooleanProperty("newfirst", request.getParameter("newfirst")))
		out.print("���������� �������� <i>newfirst</i><br>");
	if (tmpl.getProf().setBooleanProperty("photos", request.getParameter("photos")))
		out.print("���������� �������� <i>photos</i><br>");
	if (tmpl.getProf().setBooleanProperty("sortwarning", request.getParameter("sortwarning")))
		out.print("���������� �������� <i>sortwarning</i><br>");
	if (tmpl.getProf().setStringProperty("style", request.getParameter("style")))
		out.print("���������� �������� <i>style</i><br>");
	if (tmpl.getProf().setBooleanProperty("main.3columns", request.getParameter("3column")))
		out.print("���������� �������� <i>main.3columns</i><br>");
	if (tmpl.getProf().setBooleanProperty("showinfo", request.getParameter("showinfo")))
		out.print("���������� �������� <i>showinfo</i><br>");
	if (tmpl.getProf().setBooleanProperty("showanonymous", request.getParameter("showanonymous")))
		out.print("���������� �������� <i>showanonymous</i><br>");

	tmpl.writeProfile(profile);

	Cookie prof=new Cookie("profile", profile);
	prof.setMaxAge(60*60*24*31*12);
	prof.setPath("/");
	if (!tmpl.isSearchMode())
		response.addCookie(prof);

	response.setHeader("Location", tmpl.getRedirectUrl(profile));
	response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);

	out.print("Ok");
   }
%>
<p><b>��������!</b> ��������� �� ��������� ��� ���������� ��������� �����
�� ������������. ����������� ������ <i>Reload</i> ������ ��������.

<%= tmpl.DocumentFooter() %>
