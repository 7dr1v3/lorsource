<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8" import="java.sql.Connection,org.apache.commons.lang.StringUtils"  %>
<%@ page import="ru.org.linux.site.*"%>
<%@ page import="ru.org.linux.util.HTMLFormatter"%>
<% Template tmpl = Template.getTemplate(request);%>
<jsp:include page="/WEB-INF/jsp/head.jsp"/>
<%@ taglib tagdir="/WEB-INF/tags" prefix="lor" %>

<%
  Connection db = null;

  try {
    Exception error = (Exception) request.getAttribute("error");

    Message previewMsg = (Message) request.getAttribute("message");
    boolean preview = previewMsg!=null;

    db = LorDataSource.getConnection();

    if (!preview) {
      try {
        previewMsg = new Message(db,tmpl,session,request);
      } catch (MessageNotFoundException e) { }
    }

    Integer groupId = (Integer)request.getAttribute("group");

    Group group = new Group(db, groupId);

    User currentUser = User.getCurrentUser(db, session);

    if (!group.isTopicPostingAllowed(currentUser)) {
      throw new AccessViolationException("�� ���������� ���� ��� �������� ��� � ��� ������");
    }

    String mode = (String)request.getAttribute("mode");
    boolean autourl = (Boolean) request.getAttribute("autourl");

%>

<title>�������� ���������</title>
  <jsp:include page="/WEB-INF/jsp/header.jsp"/>

<%	int section=group.getSectionId();
	if (request.getAttribute("noinfo")==null || !"1".equals(request.getAttribute("noinfo"))) {
          out.print(tmpl.getObjectConfig().getStorage().readMessageDefault("addportal", String.valueOf(section), ""));
        }
%>
<% if (preview && previewMsg!=null) { %>
<h1>������������</h1>
<div class=messages>
  <lor:message db="<%= db %>" message="<%= previewMsg %>" showMenu="false" user="<%= Template.getNick(session) %>"/>
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

���������:<br>
<font size=2>(� ������ <i>Tex paragraphs</i> ������������ �������� �����.<br> ������ ������ (��� ���� Enter) �������� ����� �����)</font><br>
<textarea name=msg cols=70 rows=20><%
    if (request.getAttribute("msg")!=null) {
      out.print(HTMLFormatter.htmlSpecialChars((String)request.getAttribute("msg")));
    }
  %></textarea><br>

<% if (group.isLinksAllowed()) { %>
����� ������:
<input type=text name=linktext size=60 value="<%= request.getAttribute("linktext")==null?group.getDefaultLinkText():HTMLFormatter.htmlSpecialChars((String)request.getAttribute("linktext")) %>"><br>
������ (�� �������� <b>http://</b>)
<input type=text name=url size=70 value="<%= request.getAttribute("url")==null?"":HTMLFormatter.htmlSpecialChars((String)request.getAttribute("url")) %>"><br>
<% } %>
<% if (group.getSectionId()==1) { %>
����� (����������� �������) 
<input type=text name=tags id="tags" size=70 value="<%= request.getAttribute("tags")==null?"":StringUtils.strip((String)request.getAttribute("tags")) %>"><br>
  ���������� ����: <%= Tags.getEditTags(Tags.getTopTags(db)) %> <br>
<% } %>
<% if (!group.isLineOnly() || group.isPreformatAllowed()) {%>
<select name=mode>
<% if (!group.isLineOnly()) { %>
<option value=tex <%= (preview && mode.equals("tex"))?"selected":""%> >TeX paragraphs
<option value=ntobr <%= (preview && mode.equals("ntobr"))?"selected":""%> >User line break
<% } %>
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

<%
  if (!Template.isSessionAuthorized(session)) {
    out.print("<p><img src=\"/jcaptcha.jsp\"><input type='text' name='j_captcha_response' value=''>");
  }
%>
<br>
<input type=submit value="���������">
<input type=submit name=preview value="������������">
</form>
<%
  } finally {
    if (db!=null) {
      db.close();
    }
  }
%>
<jsp:include page="/WEB-INF/jsp/footer.jsp"/>
