<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.Connection,java.sql.Statement,java.sql.Timestamp,java.util.*,ru.org.linux.site.*,ru.org.linux.spring.TopicsListItem,ru.org.linux.util.BadImageException,ru.org.linux.util.ImageInfo"   buffer="200kb"%>
<%@ page import="ru.org.linux.util.ServletParameterParser"%>
<%@ page import="ru.org.linux.util.StringUtil"%>
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

<%
  Connection db = null;
  try {
    boolean showDeleted = (Boolean) request.getAttribute("showDeleted");
    boolean showIgnored = (Boolean) request.getAttribute("showIgnored");

    boolean firstPage = (Boolean) request.getAttribute("firstPage");
    int offset = (Integer) request.getAttribute("offset");
    Map<Integer,String> ignoreList = (Map<Integer,String>) request.getAttribute("ignoreList");

    db = LorDataSource.getConnection();
    db.setAutoCommit(false);

    Group group = (Group) request.getAttribute("group");
    int groupId = group.getId();

    Statement st = db.createStatement();

    int count = group.calcTopicsCount(db, showDeleted);
    int topics = tmpl.getProf().getInt("topics");

    int pages = count / topics;
    if (count % topics != 0) {
      count = (pages + 1) * topics;
    }

    if (group.getSectionId() == 0) {
      throw new BadGroupException();
    }

    Section section = (Section) request.getAttribute("section");

    if (firstPage || offset >= pages * topics) {
      response.setDateHeader("Expires", System.currentTimeMillis() + 90 * 1000);
    } else {
      response.setDateHeader("Expires", System.currentTimeMillis() + 30 * 24 * 60 * 60 * 1000L);
    }

    if (firstPage) {
      out.print("<title>" + group.getSectionName() + " - " + group.getTitle() + " (последние сообщения)</title>");
    } else {
      out.print("<title>" + group.getSectionName() + " - " + group.getTitle() + " (сообщения " + (count - offset) + '-' + (count - offset - topics) + ")</title>");
    }
%>
    <LINK REL="alternate" HREF="section-rss.jsp?section=<%= group.getSectionId() %>&amp;group=<%= group.getId()%>" TYPE="application/rss+xml">
<%
    out.print("<link rel=\"parent\" title=\"" + group.getTitle() + "\" href=\"view-section.jsp?section=" + group.getSectionId() + "\">");
%>
<jsp:include page="/WEB-INF/jsp/header.jsp"/>
<form action="group.jsp">
  <table class=nav>
    <tr>
    <td align=left valign=middle>
      <a href="view-section.jsp?section=<%= group.getSectionId() %>"><%= group.getSectionName() %></a> - <strong><%= group.getTitle() %></strong>
    </td>

    <td align=right valign=middle>
      [<a href="/wiki/en/lor-faq">FAQ</a>]
      [<a href="rules.jsp">Правила форума</a>]
<%
  User currentUser = User.getCurrentUser(db, session);

  if (group.isTopicPostingAllowed(currentUser)) {
%>
      [<a href="add.jsp?group=<%= groupId %>">Добавить сообщение</a>]
<%
  }
%>
  [<a href="section-rss.jsp?section=<%= group.getSectionId() %>&amp;group=<%=group.getId()%>">RSS</a>]
      <select name=group onchange="submit();" title="Быстрый переход">
<%
        List<Group> groups = Group.getGroups(db, section);

        for (Group g: groups) {
		int id = g.getId();
%>
        <option value=<%= id %> <%= id==groupId?"selected":"" %> ><%= g.getTitle() %></option>
<%
	}
%>
      </select>
     </td>
    </tr>
 </table>

</form>

<%
  out.print("<h1>");

  out.print(group.getSectionName() + ": " + group.getTitle() + "</h1>");

  if (group.getImage() != null) {
    out.print("<div align=center>");
    try {
      ImageInfo info = new ImageInfo(tmpl.getObjectConfig().getHTMLPathPrefix() + tmpl.getStyle() + group.getImage());
      out.print("<img src=\"/" + tmpl.getStyle() + group.getImage() + "\" " + info.getCode() + " border=0 alt=\"Группа " + group.getTitle() + "\">");
    } catch (BadImageException ex) {
      out.print("[bad image]");
    }
    out.print("</div>");
  }

  String des = group.getInfo();
  if (des != null) {
    out.print("<p style=\"margin-top: 0px\"><em>");
    out.print(des);
    out.print("</em></p>");
  }
%>
<form action="group.jsp" method="GET">

  <input type=hidden name=group value=<%= groupId %>>
  <!-- input type=hidden name=deleted value=<%= (showDeleted?"t":"f")%> -->
  <% if (!firstPage) { %>
    <input type=hidden name=offset value="<%= offset %>">
  <% } %>
  <div class=nav>
    фильтр: <select name="showignored" onchange="submit();">
      <option value="t" <%= (showIgnored?"selected":"") %>>все темы</option>
      <option value="f" <%= (showIgnored?"":"selected") %>>без игнорируемых</option>
      </select> [<a href="ignore-list.jsp">настроить</a>]
  </div>

</form>

<div class=forum>
<table width="100%" class="message-table">
<thead>
<tr><th>Заголовок
<%
  out.print("<span style=\"font-weight: normal\">[порядок: ");

  out.print("<b>дата отправки</b> <a href=\"group-lastmod.jsp?group=" + groupId + "\" style=\"text-decoration: underline\">дата изменения</a>");

  out.print("]</span>");
%></th><th>Автор</th><th>Число ответов<br>всего/день/час</th></tr>
</thead>
<tbody>
<%
  List<TopicsListItem> topicsList = (List<TopicsListItem>) request.getAttribute("topicsList");

  List<String> outputList = new ArrayList<String>();
  double messages = tmpl.getProf().getInt("messages");

  for (TopicsListItem topic : topicsList) {
    StringBuffer outbuf = new StringBuffer();
    int stat1 = topic.getStat1();

    Timestamp lastmod = topic.getLastmod();
    if (lastmod == null) {
      lastmod = new Timestamp(0);
    }

    outbuf.append("<tr><td>");
    if (topic.isDeleted()) {
      outbuf.append("[<a href=\"undelete.jsp?msgid=").append(topic.getMsgid()).append("\">X</a>] ");
    } else if (topic.isSticky()) {
      outbuf.append("<img src=\"img/paper_clip.gif\" width=\"15\" height=\"15\" alt=\"Прикреплено\" title=\"Прикреплено\"> ");
    }

    int pagesInCurrent = (int) Math.ceil(stat1 / messages);

    if (firstPage) {
      if (pagesInCurrent <= 1) {
        outbuf.append("<a href=\"view-message.jsp?msgid=").append(topic.getMsgid()).append("&amp;lastmod=").append(lastmod.getTime()).append("\" rev=contents>").append(StringUtil.makeTitle(topic.getSubj())).append("</a>");
      } else {
        outbuf.append("<a href=\"view-message.jsp?msgid=").append(topic.getMsgid()).append("\" rev=contents>").append(StringUtil.makeTitle(topic.getSubj())).append("</a>");
      }
    } else {
      outbuf.append("<a href=\"view-message.jsp?msgid=").append(topic.getMsgid()).append("\" rev=contents>").append(StringUtil.makeTitle(topic.getSubj())).append("</a>");
    }

    if (pagesInCurrent > 1) {
      outbuf.append("&nbsp;(стр.");

      for (int i = 1; i < pagesInCurrent; i++) {
        outbuf.append(" <a href=\"view-message.jsp?msgid=").append(topic.getMsgid());
        if ((i == pagesInCurrent - 1) && firstPage) {
          outbuf.append("&amp;lastmod=").append(lastmod.getTime());
        }
        outbuf.append("&amp;page=").append(i).append("\">");
        outbuf.append(i + 1).append("</a>");
      }
      outbuf.append(')');
    }

    outbuf.append("</td>");

    outbuf.append("<td align=center>");
    
    outbuf.append(topic.getNick());
    outbuf.append("</td>");

    outbuf.append("<td align=center>");
    int stat3 = topic.getStat3();
    int stat4 = topic.getStat4();

    if (stat1 > 0) {
      outbuf.append("<b>").append(stat1).append("</b>/");
    } else {
      outbuf.append("-/");
    }

    if (stat3 > 0) {
      outbuf.append("<b>").append(stat3).append("</b>/");
    } else {
      outbuf.append("-/");
    }

    if (stat4 > 0) {
      outbuf.append("<b>").append(stat4).append("</b>");
    } else {
      outbuf.append('-');
    }


    outbuf.append("</td></tr>");

    if (!firstPage && ignoreList != null && !ignoreList.isEmpty() && ignoreList.containsValue(topic.getNick())) {
      outbuf = new StringBuffer();
    }

    outputList.add(outbuf.toString());
  }

  if (!firstPage) {
    Collections.reverse(outputList);
  }

  for (Object anOutputList : outputList) {
    out.print((String) anOutputList);
  }
%>
</tbody>
<tfoot>
<%
  out.print("<tr><td colspan=3><p>");

  String ignoredAdd = showIgnored ?("&amp;showignored=t"):"";

  out.print("<div style=\"float: left\">");

  // НАЗАД
  if (firstPage) {
    out.print("");
  } else if (offset == pages * topics) {
    out.print("<a href=\"group.jsp?group=" + groupId + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">← начало</a> ");
  } else {
    out.print("<a rel=prev rev=next href=\"group.jsp?group=" + groupId + "&amp;offset=" + (offset + topics) + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">← назад</a>");
  }

  out.print("</div>");

  // ВПЕРЕД
  out.print("<div style=\"float: right\">");

  if (firstPage) {
    out.print("<a rel=next rev=prev href=\"group.jsp?group=" + groupId + "&amp;offset=" + (pages * topics) + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">архив →</a>");
  } else if (offset == 0 && !firstPage) {
  } else {
    out.print("<a rel=next rev=prev href=\"group.jsp?group=" + groupId + "&amp;offset=" + (offset - topics) + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">вперед →</a>");
  }

  out.print("</div>");
%>
</tfoot>
</table>
</div>
<div align=center><p>
<%
  for (int i=0; i<=pages+1; i++) {
    if (firstPage) {
      if (i != 0 && i != (pages + 1) && i > 7) {
        continue;
      }
    } else {
      if (i != 0 && i != (pages + 1) && Math.abs((pages + 1 - i) * topics - offset) > 7 * topics) {
        continue;
      }
    }

    if (i==pages+1) {
      if (offset != 0 || firstPage) {
        out.print("[<a href=\"group.jsp?group=" + groupId + "&amp;offset=0" + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">последняя</a>] ");
      } else {
        out.print("[<b>последняя</b>] ");
      }
    } else if (i==0) {
      if (firstPage) {
        out.print("[<b>первая</b>] ");
      } else {
        out.print("[<a href=\"group.jsp?group=" + groupId + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">первая</a>] ");
      }
    } else if ((pages + 1 - i) * topics == offset) {
      out.print("<b>" + (pages + 1 - i) + "</b> ");
    } else {
      out.print("<a href=\"group.jsp?group=" + groupId + "&amp;offset=" + ((pages + 1 - i) * topics) + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">" + (pages + 1 - i) + "</a> ");
    }
  }
%>
<p>
</div>

<% if (Template.isSessionAuthorized(session) && !showDeleted) { %>
  <hr>
  <form action="group.jsp" method=POST>
  <input type=hidden name=group value=<%= groupId %>>
  <input type=hidden name=deleted value=1>
  <% if (!firstPage) { %>
    <input type=hidden name=offset value="<%= offset %>">
  <% } %>
  <input type=submit value="Показать удаленные сообщения">
  </form>
  <hr>
<% } %>

<%
	st.close();
	db.commit();
%>
<%
  } finally {
    if (db != null) {
      db.close();
    }
  }
%>
<jsp:include page="/WEB-INF/jsp/footer.jsp"/>
