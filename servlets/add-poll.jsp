<%@ page import="java.sql.Connection"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>
<%@ page import="ru.org.linux.site.*"%>
<%@ page import="ru.org.linux.util.HTMLFormatter"%>
<%@ page contentType="text/html; charset=koi8-r" errorPage="error.jsp"%>
<% Template tmpl = new Template(request, config, response);%>
<%= tmpl.head() %>

<%
  response.addHeader("Cache-Control", "no-store, no-cache, must-revalidate");
  response.addHeader("Pragma", "no-cache");

  if (!Template.isSessionAuthorized(session)) {
    throw new AccessViolationException("Not authorized");
  }

  Connection db = null;
  try {
%>
<title>�������� �����</title>

<%= tmpl.DocumentHeader() %>

<%
  if ("POST".equals(request.getMethod())) {
    String title = request.getParameter("title");
    if (title == null) {
      title = "";
    }

    title = HTMLFormatter.htmlSpecialChars(title);
    if ("".equals(title)) {
      throw new BadInputException("��������� ��������� �� ����� ���� ������");
    }

    List pollList = new ArrayList();

    for (int i = 0; i < Poll.MAX_POLL_SIZE; i++) {
      String poll = request.getParameter("var" + i);

      if (poll != null) {
        pollList.add(poll);
      }
    }

    db = tmpl.getConnection("add-poll");
    db.setAutoCommit(false);

    User user = new User(db, (String) session.getAttribute("nick"));
    user.checkBlocked();

    int id = Poll.createPoll(db, title, pollList);

    out.print("������ ����� #" + id + "<br>");
    out.print("� ������ ������ ����� ����� ����� ������ ����������� �����; ��������� ���� ��� ��������");

    String logmessage = "������ ����� " + id + " ip:" + request.getRemoteAddr();
    if (request.getHeader("X-Forwarded-For") != null) {
      logmessage = logmessage + " XFF:" + request.getHeader(("X-Forwarded-For"));
    }

    tmpl.getLogger().notice("add-poll", logmessage);

    if (id > 0) {
      int guid = tmpl.getParameters().getInt("group");
      Group group = new Group(db, guid);
      //set msg -> id
      request.setAttribute("msg", "poll");
      int msgid = Message.addTopic(db, tmpl, session, request, group);
      //out.write("msgid="+msgid);
      Poll poll = new Poll(db, id);
      poll.setTopicId(db, msgid);
    }

    db.commit();
  } else {
%>

<h1>�������� �����</h1>

<form action="add-poll.jsp" method="POST">
<input type="hidden" name="group" value="19387">
<input type="hidden" name="mode" value="html">
<input type="hidden" name="autourl" value="0">
<input type="hidden" name="texttype" value="0">

  ������: <input type="text" name="title" size="40"><br>
  <%
    for (int i=0; i< Poll.MAX_POLL_SIZE; i++) {
      %>
        ������� #<%= i%>: <input type="text" name="var<%= i%>" size="40"><br>
      <%
    }
  %>
  <input type="submit" value="��������">
</form>

<%
  }
%>

<%
  } finally {
    if (db!=null) db.close();
  }
%>

<%=	tmpl.DocumentFooter() %>
