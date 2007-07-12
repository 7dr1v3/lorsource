<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="java.sql.Connection,java.sql.PreparedStatement,ru.org.linux.site.MissingParameterException,ru.org.linux.site.Template" errorPage="error.jsp"%>
<%@ page import="ru.org.linux.site.User"%>
<% Template tmpl = new Template(request, config, response); %>
<%= tmpl.head() %>
	<title>�������� ��������� �� TOP10</title>
<%= tmpl.DocumentHeader() %>
<%
if (!tmpl.isModeratorSession()) {
  throw new IllegalAccessException("Not authorized");
}
%>

<%
   if (request.getParameter("nick")==null) {
   	if (request.getParameter("msgid")==null)
		throw new MissingParameterException("msgid");

        int msgid = tmpl.getParameters().getInt("msgid");
%>
<h1>�������� ��������� �� TOP10</h1>
������ ����� ������������� ��� ��������������� ����� � �������������,
������� ����� ������������� ���������.
<form method=POST action="notop.jsp">
<input type=hidden name=msgid value="<%= msgid %>"><br>
<input type=submit value="Submit/�����������">
</form>
<%
   } else {
      Connection db = null;
      try {
        int msgid = tmpl.getParameters().getInt("msgid");

	db = tmpl.getConnection("notop");
	db.setAutoCommit(false);
	PreparedStatement pst=db.prepareStatement("UPDATE topics SET notop='t' WHERE id=?");
	pst.setInt(1, msgid);

	User user=new User(db, Template.getNick(session));
	user.checkCommit();

	pst.executeUpdate();

        out.print("��������� ������� �� top10");

	tmpl.getLogger().notice("commit", "������� �� TOP10 ��������� "+msgid+" ������������� "+user.getNick());
	pst.close();

	db.commit();

      } finally {
        if (db!=null) db.close();
      }
   }
%>
<%=	tmpl.DocumentFooter() %>
