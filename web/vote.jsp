<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8" %>
<%@ page
    import="java.sql.Connection,java.sql.Statement,javax.servlet.http.HttpServletResponse"
      %>
<%@ page import="ru.org.linux.site.*"%>
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
<jsp:include page="/WEB-INF/jsp/head.jsp"/>

<title>��� ����� ������</title>
<jsp:include page="WEB-INF/jsp/header.jsp"/>

<%
  if (!Template.isSessionAuthorized(session)) {
    throw new AccessViolationException("Not authorized");
  }

  Connection db = null;
  try {
%>

<H1>��� ����� ������</H1>
<%
    if (request.getParameter("vote") == null) {
      throw new BadInputException("������ �� �������");
    }

    int vote = Integer.parseInt(request.getParameter("vote"));
    int voteid = Integer.parseInt(request.getParameter("voteid"));
    int msgid = Integer.parseInt(request.getParameter("msgid"));

    db = LorDataSource.getConnection();

    if (voteid != Poll.getCurrentPollId(db)) {
      throw new BadVoteException("���������� ����� ������ � ������� �����");
    }

    Integer last = (Integer) session.getValue("poll.voteid");
    if (last == null || last != voteid) {
      Statement st = db.createStatement();

      if (st.executeUpdate("UPDATE votes SET votes=votes+1 WHERE id=" + vote + " AND vote=" + voteid) == 0) {
        throw new BadVoteException(vote, voteid);
      }

      session.putValue("poll.voteid", voteid);
      st.close();
    }

    response.setHeader("Location", tmpl.getMainUrl() + "view-message.jsp?msgid=" + msgid + "&highlight=" + vote);
    response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);

  } finally {
    if (db != null) {
      db.close();
    }
  }

%>
<jsp:include page="WEB-INF/jsp/footer.jsp"/>
