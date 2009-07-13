<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet,java.sql.Statement,java.util.logging.Logger"   buffer="60kb" %>
<%@ page import="ru.org.linux.site.LorDataSource" %>
<%@ page import="ru.org.linux.site.Template" %>
<%@ page import="ru.org.linux.util.ServletParameterParser" %>
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

<%
  Logger logger = Logger.getLogger("ru.org.linux");
%>
<jsp:include page="/WEB-INF/jsp/head.jsp"/>
<%
  if (!Template.isSessionAuthorized(session) || !((Boolean) session.getValue("moderator"))) {
    throw new IllegalAccessException("Not authorized");
  }

  out.println("<title>Перенос новости...</title>");
  %>
<jsp:include page="WEB-INF/jsp/header.jsp"/>
<%
  Connection db = null;

  try {
    int msgid = new ServletParameterParser(request).getInt("msgid");
    db = LorDataSource.getConnection();
    Statement st1 = db.createStatement();
    if (request.getMethod().equals("POST")) {
      String newgr = request.getParameter("moveto");
      String sSql = "UPDATE topics SET groupid=" + newgr + " WHERE id=" + msgid;
      // out.println(sSql);
      PreparedStatement pst = db.prepareStatement("SELECT topics.groupid,topics.userid,groups.title FROM topics,groups WHERE topics.id=? AND groups.id=topics.groupid");
      pst.setInt(1, msgid);
      ResultSet rs = pst.executeQuery();
      String oldgr = "n/a";
      if (rs.next()) {
        oldgr = rs.getString("groupid");
      }
      st1.executeUpdate(sSql);
      logger.info("topic " + msgid + " moved" +
          " by " + session.getValue("nick") + " from group " + oldgr + " to group " + newgr);
    } else {
      out.println("перенос новости <strong>" + msgid + "</strong> в группу:");
      ResultSet rs = st1.executeQuery("SELECT id,title FROM groups WHERE section=1 ORDER BY id");
%>
<form method="post" action="mt.jsp">
<input type=hidden name="msgid" value='<%= msgid %>'>
<select name="moveto">
<%
        while (rs.next()) {
          out.println("<option value='"+rs.getInt("id")+"'>"+rs.getString("title")+"</option>");
        }

        rs.close();
        st1.close();
        out.println("</select>\n<input type='submit' name='move' value='move'>\n</form>");
      }
    } finally {
        if (db!=null) {
          db.close();
        }
    }
%>

  <jsp:include page="WEB-INF/jsp/footer.jsp"/>
