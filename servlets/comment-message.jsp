<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="java.sql.Connection,javax.servlet.http.HttpServletResponse,ru.org.linux.site.AccessViolationException,ru.org.linux.site.Message,ru.org.linux.site.Template" errorPage="error.jsp" buffer="200kb"%>
<%@ page import="ru.org.linux.util.HTMLFormatter"%>
<% Template tmpl = new Template(request, config, response); %>
<%= tmpl.head() %>
<%
  Connection db=null;

  try {
   int msgid = tmpl.getParameters().getInt("msgid");

   int npage=-1;
   if (request.getParameter("page")!=null)
   	npage=tmpl.getParameters().getInt("page");

   String returnUrl="view-message.jsp?msgid="+msgid;
   if (npage!=-1) returnUrl+="&amp;page="+npage;

   boolean show_deleted=request.getParameter("deleted")!=null;

   if (show_deleted && !"POST".equals(request.getMethod())) {
	response.setHeader("Location",tmpl.getRedirectUrl()+returnUrl);
	response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);

	show_deleted=false;
   }

   db = tmpl.getConnection("view-message");

   Message message = new Message(db, msgid);

   if (message.isExpired() && show_deleted)
   	throw new AccessViolationException("������ ���������� ��������� ����������� � ���������� �����");
   if (message.isExpired() && message.isDeleted())
   	throw new AccessViolationException("������ ���������� ���������� ��������� ���������");

   out.print("<title>"+message.getPortalTitle()+" - "+message.getGroupTitle()+" - "+message.getTitle()+"</title>");
%>
<%= tmpl.DocumentHeader() %>

<div class=messages>

<%
   out.print(message.printMessage(tmpl, db, true));
%>
</div>

<% if (message.isCommentEnabled() && !message.isExpired() && !message.isDeleted() && !show_deleted) { %>

<h2><a name=rep>�������� ���������:</a></h2>
<% if (tmpl.getProf().getBoolean("showinfo") && !tmpl.isSessionAuthorized(session)) { %>
<font size=2>����� ������ ��������� ���������, ����������� login `anonymous',
��� ������. ���� �� ����������� ������� ����������� � ������,
�������� ������� �� ������� ��������,
<a href="register.jsp">�����������������</a></font>.
<p>

<% } %>
<font size=2><strong>��������!</strong> ����� ���������� ����������� ������������ �
<a href="rules.jsp">���������</a> �����.</font><p>

<%
  out.print(Message.getPostScoreInfo(message.getPostScore()));
%>

<form method=POST action="add_comment.jsp">
  <input type="hidden" name="session" value="<%= HTMLFormatter.htmlSpecialChars(session.getId()) %>">  
<% if (session==null || session.getAttribute("login")==null || !((Boolean) session.getAttribute("login")).booleanValue()) { %>
���:
<input type=text name=nick value="<%= tmpl.getCookie("NickCookie","anonymous") %>" size=40><br>
������:
<input type=password name=password size=40><br>
<% } %>
<% out.print("<input type=hidden name=topic value="+msgid+ '>'); %>
<input type=hidden name=return value="<%= returnUrl %>">
��������:
<input type=text name=title size=40 value="Re: <%= message.getTitle() %>"><br>
���������:<br>
<font size=2>(� ������ <i>Tex paragraphs</i> ������������ �������� �����.<br> ������ ������ (��� ���� Enter) �������� ����� �����.<br> ���� '&gt;' � ������ ������ �������� ����� �������� �����������)</font><br>
<textarea name=msg cols=70 rows=20 onkeypress="return ctrl_enter(event, this.form);"></textarea><br>

<select name=mode>
<option value=quot>TeX paragraphs w/quoting
<option value=tex>TeX paragraphs w/o quoting
<option value=ntobr>User line breaks
<option value=pre>Preformatted text
</select>

<select name=autourl>
<option value=1>Auto URL
<option value=0>No Auto URL
</select>

<input type=hidden name=texttype value=0>
<br>

<%
  out.print(Message.getPostScoreInfo(message.getPostScore()));
%>

<br>

  <%  
  if (!Template.isSessionAuthorized(session)) {
    out.print("<p><img src=\"/jcaptcha.jsp\"><input type='text' name='j_captcha_response' value=''>");
  }
%>

<input type=submit value="Post/���������">
</form>

<% } %>
<%
  } finally {
    if (db!=null) db.close();
  }
%>
<%=	tmpl.DocumentFooter() %>
