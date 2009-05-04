<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.Connection"   buffer="200kb"%>
<%@ page import="ru.org.linux.site.AccessViolationException" %>
<%@ page import="ru.org.linux.site.LorDataSource" %>
<%@ page import="ru.org.linux.site.Message" %>
<%@ page import="ru.org.linux.site.Template" %>
<%@ page import="ru.org.linux.util.HTMLFormatter" %>
<%@ page import="ru.org.linux.util.ServletParameterParser" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="lor" %>
<%--
  ~ Copyright 1998-2009 Linux.org.ru
  ~    Licensed under the Apache License, Version 2.0 (the "License");
  ~    you may not use this file except in compliance with the License.
  ~    You may obtain a copy of the License at
  ~
  ~        http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~    Unless required by applicable law or agreed to in writing, software
  ~    distributed under the License is distributed on an "AS IS" BASIS,
  ~    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  ~    See the License for the specific language governing permissions and
  ~    limitations under the License.
  --%>

<% Template tmpl = Template.getTemplate(request); %>
<jsp:include page="WEB-INF/jsp/head.jsp"/>

<%
  Connection db = null;

  try {
    int msgid = new ServletParameterParser(request).getInt("msgid");

    db = LorDataSource.getConnection();

    Message message = new Message(db, msgid);

    if (message.isExpired()) {
      throw new AccessViolationException("������ �������������� ���������� ����");
    }

    if (message.isDeleted()) {
      throw new AccessViolationException("������ �������������� ��������� ���������");
    }

    out.print("<title>" + message.getSectionTitle() + " - " + message.getGroupTitle() + " - " + message.getTitle() + "</title>");
%>
<jsp:include page="WEB-INF/jsp/header.jsp"/>
<div class=messages>
  <lor:message db="<%= db %>" message="<%= message %>" showMenu="false" user="<%= Template.getNick(session) %>"/>
</div>

<h2><a name=rep>�������� ���������:</a></h2>
<%--<% if (tmpl.getProf().getBoolean("showinfo") && !Template.isSessionAuthorized(session)) { %>--%>
<%--<font size=2>����� ������ ��������� ���������, ����������� login `anonymous',--%>
<%--��� ������. ���� �� ����������� ������� ����������� � ������,--%>
<%--�������� ������� �� ������� ��������,--%>
<%--<a href="register.jsp">�����������������</a></font>.--%>
<%--<p>--%>

<%--<% } %>--%>
<font size=2><strong>��������!</strong> ����� ���������� ����������� ������������ �
<a href="rules.jsp">���������</a> �����.</font><p>

<%
  out.print(Message.getPostScoreInfo(message.getPostScore()));
%>

<form method=POST action="add_comment.jsp">
  <input type="hidden" name="session" value="<%= HTMLFormatter.htmlSpecialChars(session.getId()) %>">  
<% if (session == null || session.getAttribute("login") == null || !(Boolean) session.getAttribute("login")) { %>
���:
<input type=text name=nick value="anonymous" size=40><br>
������:
<input type=password name=password size=40><br>
<% } %>
<% out.print("<input type=hidden name=topic value="+msgid+ '>'); %>
��������:
<input type=text name=title size=40 value="Re: <%= message.getTitle() %>"><br>
���������:<br>
<font size=2>(� ������ <i>Tex paragraphs</i> ������������ �������� �����.<br> ������ ������ (��� ���� Enter) �������� ����� �����.<br> ���� '&gt;' � ������ ������ �������� ����� �������� �����������)</font><br>
<textarea name=msg cols=70 rows=20 onkeypress="return ctrl_enter(event, this.form);"></textarea><br>

<% String mode = tmpl.getFormatMode(); %>
<select name=mode>
<option value=ntobrq <%= "ntobrq".equals(mode)?"selected":""%> >User line breaks w/quoting
<option value=quot <%= "quot".equals(mode)?"selected":""%> >TeX paragraphs w/quoting
<option value=tex <%= "tex".equals(mode)?"selected":""%> >TeX paragraphs w/o quoting
<option value=ntobr <%= "ntobr".equals(mode)?"selected":""%> >User line breaks w/o quoting
<option value=pre  <%= "pre".equals(mode)?"selected":""%> >Preformatted text
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

  <lor:captcha/>

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
<jsp:include page="WEB-INF/jsp/footer.jsp"/>
