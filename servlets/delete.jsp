<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet" errorPage="error.jsp"%>
<%@ page import="ru.org.linux.site.*"%>
<% Template tmpl = new Template(request, config, response); %>
<%= tmpl.head() %>
	<title>�������� ���������</title>
<%= tmpl.DocumentHeader() %>

<%
   if (request.getParameter("reason")==null) {
   	if (request.getParameter("msgid")==null)
		throw new MissingParameterException("msgid");
%>
<script language="Javascript">
<!--
function change(dest,source)
{
	dest.value = source.options[source.selectedIndex].value;
}
   // -->
</script>
<h1>�������� ���������</h1>
�� ������ ������� ���� ��������� � ������� ���� � �������
��� ���������.
<form method=POST action="delete.jsp">
<table>
<% if (session==null || session.getAttribute("login")==null || !((Boolean) session.getAttribute("login")).booleanValue()) { %>
<tr>
<td>���:</td>
<td><input type=text name=nick size=40>
</td>
</tr>
<tr>
<td>������:</td>
<td><input type=password name=password size=40></td>
</tr>
<% } %>
<tr>
<td>������� ��������<br>�������� �� ���� ��� �������� ����</td>
<td>
<select name=reason_select onChange="change(reason,reason_select)">
<option value="">
<option value="3.1 �����">3.1 �����
<option value="3.2 �������� ���������">3.2 �������� ���������
<option value="3.3 ������������ ��������������">3.3 ������������ ��������������
<option value="3.4 ������ ���������">3.4 ������ ���������
<option value="4.1 Offtopic">4.1 Offtopic
<option value="4.2 ��������� �������� ����������">4.2 ��������� �������� ����������
<option value="4.3 ���������� flame">4.3 ���������� flame
<option value="4.4 ���������� �������� �����������">4.4 ���������� �������� �����������
<option value="4.5 �������� ���������">4.5 �������� ���������
<option value="4.6 ����">4.6 ����
<option value="4.7 ����">4.7 ����
<option value="5.1 ����������� ���������">5.1 ����������� ���������
<option value="5.2 ����������� ���������� ���������">5.2 ����������� ���������� ���������
<option value="5.3 ������������/������������ �����">5.3 ������������/������������ �����
<option value="5.4 ������ ���������">5.4 ������ ���������
<option value="5.5 �������������� ��������� ������ �������� �����">5.5 �������������� ��������� ������ �������� �����
<option value="6 ��������� copyright">6 ��������� copyright
<option value="6.2 Warez">6.2 Warez
<option value="7.1 ����� �� ������������ ���������">7.1 ����� �� ������������ ���������
</select>
</td>
<tr><td></td>
<td><input type=text name=reason size=40></td>
</tr>
</table>
<input type=hidden name=msgid value="<%= request.getParameter("msgid") %>">
<input type=submit value="Delete/�������">
</form>
<%
   } else {
     Connection db = null;
     try {
       int msgid = Integer.parseInt(request.getParameter("msgid"));
       String nick = request.getParameter("nick");
       String reason = request.getParameter("reason");

       db = tmpl.getConnection("delete");
       db.setAutoCommit(false);

       PreparedStatement lock = db.prepareStatement("SELECT deleted FROM topics WHERE id=? FOR UPDATE");
       PreparedStatement st1 = db.prepareStatement("UPDATE topics SET deleted='t' WHERE id=?");
       PreparedStatement st2 = db.prepareStatement("INSERT INTO del_info (msgid, delby, reason) values(?,?,?)");
       lock.setInt(1, msgid);
       st1.setInt(1, msgid);
       st2.setInt(1, msgid);
       st2.setString(3, reason);

       User user;

       if (session == null || session.getAttribute("login") == null || !((Boolean) session.getAttribute("login")).booleanValue())
       {
         if (request.getParameter("nick") == null) {
           throw new BadInputException("�� ��� ����� �� �������");
         }
         user = new User(db, nick);
         user.checkPassword(request.getParameter("password"));
       } else {
         user = new User(db, (String) session.getAttribute("nick"));
         nick = (String) session.getAttribute("nick");
       }

       user.checkAnonymous();
       st2.setInt(2, user.getId());

       ResultSet lockResult = lock.executeQuery(); // lock another delete.jsp on this row

       if (lockResult.next() && lockResult.getBoolean("deleted")) {
         throw new UserErrorException("��������� ��� �������");
       }

       PreparedStatement pr = db.prepareStatement("SELECT postdate>CURRENT_TIMESTAMP-'1 hour'::interval as perm FROM users, topics WHERE topics.id=? AND topics.userid=users.id AND users.nick=?");
       pr.setInt(1, msgid);
       pr.setString(2, nick);
       ResultSet rs = pr.executeQuery();
       boolean perm = false;

       if (rs.next()) {
         perm = rs.getBoolean("perm");
       }

       rs.close();

       if (!perm) {
         PreparedStatement mod = db.prepareStatement("SELECT moderator FROM groups,topics WHERE topics.groupid=groups.id AND topics.id=?");
         mod.setInt(1, msgid);

         rs = mod.executeQuery();

         if (!rs.next()) {
           throw new MessageNotFoundException(msgid);
         }

         if (rs.getInt("moderator") == user.getId()) {
           perm = true; // NULL is ok
         }

         mod.close();
         rs.close();
       }

       if (!perm) {
         PreparedStatement mod = db.prepareStatement("SELECT topics.moderate as mod, sections.moderate as needmod FROM groups,topics,sections WHERE topics.groupid=groups.id AND topics.id=? AND groups.section=sections.id");
         mod.setInt(1, msgid);

         rs = mod.executeQuery();
         if (!rs.next()) {
           throw new MessageNotFoundException(msgid);
         }

         if (rs.getBoolean("needmod") && !rs.getBoolean("mod") && user.canModerate()) {
           perm = true;
         }

         rs.close();
       }

       if (!perm && user.canModerate()) {
         PreparedStatement mod = db.prepareStatement("SELECT postdate>CURRENT_TIMESTAMP-'1 month'::interval as perm, section FROM topics,groups WHERE topics.groupid=groups.id AND topics.id=?");
         mod.setInt(1, msgid);

         rs = mod.executeQuery();
         if (!rs.next()) {
           throw new MessageNotFoundException(msgid);
         }

         if (rs.getBoolean("perm") || rs.getInt("section")==Message.SECTION_LINKS) {
           perm = true;
         }

         rs.close();
       }

       if (!perm) {
         user.checkDelete();
       }

       st1.executeUpdate();
       st2.executeUpdate();

       out.print("��������� �������");
       tmpl.getLogger().notice("delete", "������� ��������� " + msgid + " ������������� " + nick + " �� ������� `" + reason + '\'');

       st1.close();
       st2.close();
       db.commit();
     } finally {
       if (db != null) {
         db.close();
       }
     }
   }
%>
<%= tmpl.DocumentFooter() %>
