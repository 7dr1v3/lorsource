<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="java.sql.Connection,java.util.Date, javax.servlet.http.Cookie, javax.servlet.http.HttpServletResponse, ru.org.linux.site.BadInputException, ru.org.linux.site.Template, ru.org.linux.site.User" errorPage="error.jsp"%>
<% Template tmpl = new Template(request, config, response); %>
<%= tmpl.head() %>
<title>���������</title>
<%= tmpl.DocumentHeader() %>
<h1>���������</h1>

<form method=POST action="login.jsp">
  <table>
    <tr>
      <td>Nick:</td>
      <td><input type=text name=nick></td>
    </tr>

    <tr>
      <td>������:</td>
      <td><input type=password name=passwd></td>
    </tr>

    <tr>
      <td>��� ����������:</td>
      <td><input type=text name=activate></td>
    </tr>

  </table>

  <input type=submit value="������������">
</form>

<%=	tmpl.DocumentFooter() %>
