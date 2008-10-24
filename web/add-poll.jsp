<%@ page import="ru.org.linux.site.AccessViolationException"%>
<%@ page import="ru.org.linux.site.Poll"%>
<%@ page import="ru.org.linux.site.Template"%>
<%@ page import="ru.org.linux.util.HTMLFormatter"%>
<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"  %>
<jsp:include page="/WEB-INF/jsp/head.jsp"/>


<%
//  response.addHeader("Cache-Control", "no-store, no-cache, must-revalidate");
//  response.addHeader("Pragma", "no-cache");

  if (!Template.isSessionAuthorized(session)) {
    throw new AccessViolationException("Not authorized");
  }

%>
<title>�������� �����</title>

<jsp:include page="WEB-INF/jsp/header.jsp"/>

<h1>�������� �����</h1>

<form action="add.jsp" method="POST">
<input type="hidden" name="session" value="<%= HTMLFormatter.htmlSpecialChars(session.getId()) %>">  
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

<jsp:include page="WEB-INF/jsp/footer.jsp"/>
