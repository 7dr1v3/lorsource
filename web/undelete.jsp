<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet"  %>
<%@ page import="java.util.logging.Logger"%>
<%@ page import="ru.org.linux.site.*" %>
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

<%  Template tmpl = Template.getTemplate(request);
  Logger logger = Logger.getLogger("ru.org.linux");
%>
<jsp:include page="WEB-INF/jsp/head.jsp"/>

        <title>�������������� ���������</title>
<jsp:include page="WEB-INF/jsp/header.jsp"/>

<%

if (!tmpl.isModeratorSession()) {
  throw new AccessViolationException("Not authorized");
}

Connection db = null;
try {

  db = LorDataSource.getConnection();

  if (request.getParameter("msgid")==null) {
    throw new MissingParameterException("msgid");
  }
  int msgid = Integer.parseInt(request.getParameter("msgid"));

  Message message = new Message(db, msgid);

  if (message.isExpired()) {
    throw new AccessViolationException("������ ��������������� ���������� ���������");
  }

  if (!message.isDeleted()) {
    throw new AccessViolationException("��������� ��� �������������");
  }

  if (message.getSectionId()!=1) {
    throw new AccessViolationException("����� ��������������� ������ �������"); 
  }


  if (request.getParameter("undel")==null) {
%>
<h1>�������������� ���������</h1>
�� ������ ������������ ���̣���� ���������.
<form method=POST action="undelete.jsp">
<input type=hidden name=msgid value="<%= request.getParameter("msgid") %>">
<div class=messages>
  <lor:message db="<%= db %>" message="<%= message %>" showMenu="false"/> 
</div>
<input type=submit name=undel value="Undelete/������������">
</form>
<%
  } else {
    db.setAutoCommit(false);

    PreparedStatement lock = db.prepareStatement("SELECT deleted FROM topics WHERE id=? FOR UPDATE");
    PreparedStatement st1 = db.prepareStatement("UPDATE topics SET deleted='f' WHERE id=?");
    PreparedStatement st2 = db.prepareStatement("DELETE FROM del_info WHERE msgid=?");
    lock.setInt(1, msgid);
    st1.setInt(1, msgid);
    st2.setInt(1, msgid);

    String nick;

    if (session == null || session.getAttribute("login") == null || !(Boolean) session.getAttribute("login")) {
      throw new BadInputException("�� ��� ����� �� �������");
    } else {
      nick = (String) session.getAttribute("nick");
    }

    ResultSet lockResult = lock.executeQuery(); // lock another undelete.jsp on this row

    if (lockResult.next() && !lockResult.getBoolean("deleted")) {
      throw new UserErrorException("��������� ��� �������������");
    }

    st1.executeUpdate();
    st2.executeUpdate();

    out.print("��������� �������������");
    logger.info("������������� ��������� " + msgid + " ������������� " + nick);

    st1.close();
    st2.close();

    db.commit();
  }
} finally {
  if (db != null) {
    db.close();
  }
}
%>
<jsp:include page="WEB-INF/jsp/footer.jsp"/>
