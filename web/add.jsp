<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8" import="java.sql.Connection,java.util.Random" errorPage="/error.jsp"%>
<%@ page import="ru.org.linux.site.*"%>
<%@ page import="ru.org.linux.util.HTMLFormatter"%>
<%@ page import="ru.org.linux.util.UtilBadURLException"%>
<% Template tmpl = new Template(request, config, response);%>
<%= tmpl.head() %>
<%
  Connection db = null;
  Message previewMsg = null;

  try {

    boolean showform = request.getMethod().equals("GET");
    boolean preview = false;
    Exception error = null;

    if (request.getMethod().equals("POST")) {
      try {
        preview = true;

        db = tmpl.getConnection();
        db.setAutoCommit(false);

        previewMsg = new Message(db, tmpl, session, request);

        String returnUrl = (String) request.getAttribute("return");
        preview = previewMsg.isPreview();

        if (!preview) {

          int msgid = previewMsg.addTopicFromPreview(db, tmpl, session, request);

          Group group = new Group(db, previewMsg.getGroupId());

          Random random = new Random();

          if (!group.isModerated()) {
            if (returnUrl == null || "".equals(returnUrl)) {
              returnUrl = "view-message.jsp?msgid=" + msgid;
            }
            response.setHeader("Location", tmpl.getMainUrl() + returnUrl + "&nocache=" + random.nextInt());
            response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);
          }
%>
<title>���������� ��������� ������ �������</title>
<%= tmpl.DocumentHeader() %>
<% if (group.isModerated()) { %>
�� ��������� ��������� � ���������� ������. ���������, ���� ���� ��������� ��������.
<% } %>
<p>��������� �������� �������
<% if (group.isModerated()) { %>
<p>����������, ��������� ���� ��������� � ����������������� ������ � ��� � <a href="view-all.jsp?nocache=<%= random.nextInt()%>">������ ���������������� ���������</a>
<% } %>

<p><a href="<%= tmpl.getMainUrl()+returnUrl %>">�������</a>

<p><b>����������, �� ��������� ������ "ReLoad" ������ �������� �� ���� ��������� � �� ������������� �� ��� �� ��������� ������ Back</b>
<%
	  } else {
		showform = true;
	  }
    } catch (UserErrorException e) {
      error=e;
      showform=true;
      if (db!=null) {
        db.rollback();
	db.setAutoCommit(true);
      }
    } catch (UserNotFoundException e) {
      error=e;
      showform=true;
      if (db!=null) {
        db.rollback();
	db.setAutoCommit(true);
      }
    } catch (UtilBadURLException e) {
      error=e;
      showform=true;
      if (db!=null) {
        db.rollback();
	db.setAutoCommit(true);
      }
    }
  }

  if (showform || preview) {

	if (!preview && previewMsg==null) { 
	  try { 
		previewMsg = new Message(db,tmpl,session,request);
	  } catch (MessageNotFoundException e) { }
	}

    Integer groupId = (Integer)request.getAttribute("group");

    db = tmpl.getConnection();
    Group group = new Group(db, groupId);

    User currentUser = User.getCurrentUser(db, session);

    if (!group.isTopicPostingAllowed(currentUser)) {
      throw new AccessViolationException("�� ���������� ���� ��� �������� ��� � ��� ������");
    }

    String mode = (String)request.getAttribute("mode");
    boolean texttype = (Boolean) request.getAttribute("texttype");
    boolean autourl = (Boolean) request.getAttribute("autourl");

%>

<title>�������� ���������</title>
<%= tmpl.DocumentHeader() %>
<%	int section=group.getSectionId();
	if (request.getAttribute("noinfo")==null || !"1".equals(request.getAttribute("noinfo")))
		out.print(tmpl.getObjectConfig().getStorage().readMessageDefault("addportal", String.valueOf(section), ""));
%>
<% if (preview && previewMsg!=null) { %>
<h1>������������</h1>
<div class=messages>
<%
    out.print(previewMsg.printMessage(tmpl, db, false, Template.getNick(session), 0));
%>
</div>
<% } %>
<% if (error==null) { %>
<h1>��������</h1>
<% } else { out.println("<h1>������: "+error.getMessage()+"</h1>"); } %>
<% if (tmpl.getProf().getBoolean("showinfo") && !Template.isSessionAuthorized(session)) { %>
<font size=2>����� ������ ��������� ���������, ����������� login `anonymous',
��� ������. ���� �� ����������� ������� ����������� � ������,
�������� ������� �� ������� ��������,
<a href="register.jsp">�����������������</a></font>.
<p>

<% if (!group.isLineOnly()) { %>
<font size=2>� HTML ������ ����� ������������ ���� &lt;a&gt; &lt;p&gt; &lt;li&gt; </font>
<% } %>
<% } %>

<% if (group.isImagePostAllowed()) { %>
<p>
  ����������� ���������� � �����������:
  <ul>
    <li>������ x ������: �� 400x400 �� 2048x2048 ��������</li>
    <li>���: jpeg, gif, png</li>
    <li>������ �� ����� 300 Kb</li>
  </ul>
</p>
<%   } %>
<form method=POST action="add.jsp" <%= group.isImagePostAllowed()?"enctype=\"multipart/form-data\"":"" %> >
  <input type="hidden" name="session" value="<%= HTMLFormatter.htmlSpecialChars(session.getId()) %>">
<%  if (request.getAttribute("noinfo")!=null) {
  %>
  <input type="hidden" name="noinfo" value="<%= request.getAttribute("noinfo") %>">
 <% }
%>
<% if (session == null || session.getValue("login") == null || !(Boolean) session.getValue("login")) { %>
���:
<input type=text name=nick value="<%= request.getAttribute("nick")==null?"anonymous":HTMLFormatter.htmlSpecialChars((String)request.getAttribute("nick")) %>" size=40><br>
������:
<input type=password name=password size=40><br>
<% } %>
<input type=hidden name=group value="<%= groupId %>">

<% if (request.getAttribute("return")!=null) { %>
<input type=hidden name=return value="<%= HTMLFormatter.htmlSpecialChars((String)request.getAttribute("return")) %>">
<% } %>

��������:
<input type=text name=title size=40 value="<%= request.getAttribute("title")==null?"":HTMLFormatter.htmlSpecialChars((String)request.getAttribute("title")) %>" ><br>

  <% if (group.isImagePostAllowed()) { %>
  �����������:
  <input type="file" name="image"><br>
  <% } %>

<% if (group.isLinksAllowed() && group.isLinksUp()) { %>
<input type=hidden name=linktext value="<%= group.getDefaultLinkText() %> ">
������ (�� �������� <b>http://</b>)
<input type=text name=url size=70 value="<%= request.getAttribute("url")==null?"":HTMLFormatter.htmlSpecialChars((String)request.getAttribute("url")) %>"><br>
<% } %>

���������:<br>
<font size=2>(� ������ <i>Tex paragraphs</i> ������������ �������� �����.<br> ������ ������ (��� ���� Enter) �������� ����� �����)</font><br>
<textarea name=msg cols=70 rows=20><%
    if (request.getAttribute("msg")!=null) {
      out.print(HTMLFormatter.htmlSpecialChars((String)request.getAttribute("msg")));
    }
  %></textarea><br>

<% if (group.isLinksAllowed() && !group.isLinksUp()) { %>
����� ������:
<input type=text name=linktext size=60 value="<%= request.getAttribute("linktext")==null?group.getDefaultLinkText():HTMLFormatter.htmlSpecialChars((String)request.getAttribute("linktext")) %>"><br>
������ (�� �������� <b>http://</b>)
<input type=text name=url size=70 value="<%= request.getAttribute("url")==null?"":HTMLFormatter.htmlSpecialChars((String)request.getAttribute("url")) %>"><br>
<% } %>

<% if (!group.isLineOnly() || group.isPreformatAllowed()) {%>
<select name=mode>
<% if (!group.isLineOnly()) { %>
<option value=tex <%= (preview && mode.equals("tex"))?"selected":""%> >TeX paragraphs
<option value=ntobr <%= (preview && mode.equals("ntobr"))?"selected":""%> >User line break
<% } %>
<option value=html <%= (preview && mode.equals("html"))?"selected":""%> >Ignore line breaks
<% if (group.isPreformatAllowed()) { %>
<option value=pre <%= (preview && mode.equals("pre"))?"selected":""%> >Preformatted text
<% } %>
<% } else { %>
<input type=hidden name=mode value=html>
<% } %>

</select>

<select name=autourl>
<option value=1 <%= (preview && autourl)?"selected":""%> >Auto URL
<option value=0 <%= (preview && !autourl)?"selected":""%> >No Auto URL
</select>

<% if (!group.isLineOnly()) { %>
<select name=texttype>
<option value=0 <%= (preview && !texttype)?"selected":""%> >Plain text
<option value=1 <%= (preview && texttype)?"selected":""%> >HTML (limited)
</select>
<% } else { %>
<input type=hidden name=texttype value=0>
<% } %>

<%
  if (!Template.isSessionAuthorized(session)) {
    out.print("<p><img src=\"/jcaptcha.jsp\"><input type='text' name='j_captcha_response' value=''>");
  }
%>
<br>
<input type=submit value="���������">
<input type=submit name=preview value="������������">
</form>
<%}
  } finally {
    if (db!=null) db.close();
  }
%>
<%=	tmpl.DocumentFooter() %>
