<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"%>
<%@ page import="java.net.URLEncoder,java.sql.Connection,java.sql.ResultSet,java.sql.Statement,java.sql.Timestamp,java.util.ArrayList,java.util.Collections,java.util.List" errorPage="/error.jsp" buffer="200kb"%>
<%@ page import="java.util.Map"%>
<%@ page import="javax.servlet.http.HttpServletResponse"%>
<%@ page import="ru.org.linux.site.*"%>
<%@ page import="ru.org.linux.util.BadImageException" %>
<%@ page import="ru.org.linux.util.ImageInfo" %>
<%@ page import="ru.org.linux.util.StringUtil" %>
<% Template tmpl = new Template(request, config, response); %>
<%= tmpl.head() %>
<%
  Connection db = null;
  try {
    int groupId = Integer.parseInt(request.getParameter("group"));
    boolean showDeleted = request.getParameter("deleted") != null;

    if (showDeleted && !"POST".equals(request.getMethod())) {
      response.setHeader("Location", tmpl.getMainUrl() + "/group.jsp?group=" + groupId);
      response.setStatus(HttpServletResponse.SC_MOVED_PERMANENTLY);

      showDeleted = false;
    }

    if (showDeleted && !Template.isSessionAuthorized(session)) {
      throw new AccessViolationException("�� �� ������������");
    }

    boolean showIgnored = tmpl.getProf().getBoolean("showignored");
    if (request.getParameter("showignored") != null) {
      showIgnored = "t".equals(request.getParameter("showignored"));
    }

    if (request.getParameter("group") == null) {
      throw new MissingParameterException("group");
    }

    boolean firstPage;
    int offset;

    if (request.getParameter("offset") != null) {
      offset = Integer.parseInt(request.getParameter("offset"));
      firstPage = false;
    } else {
      firstPage = true;
      offset = 0;
    }

    String returnUrl;
    if (offset > 0) {
      returnUrl = "group.jsp?group=" + groupId + "&amp;offset=" + offset;
    } else {
      returnUrl = "group.jsp?group=" + groupId;
    }

    db = tmpl.getConnection();
    db.setAutoCommit(false);

    Group group = new Group(db, groupId);

    Statement st = db.createStatement();

    ResultSet rs;
    if (showDeleted) {
      rs = st.executeQuery("SELECT count(topics.id) FROM topics,groups,sections WHERE (topics.moderate OR NOT sections.moderate) AND groups.section=sections.id AND topics.groupid=" + groupId + " AND groups.id=" + groupId);
    } else {
      rs = st.executeQuery("SELECT count(topics.id) FROM topics,groups,sections WHERE (topics.moderate OR NOT sections.moderate) AND groups.section=sections.id AND topics.groupid=" + groupId + " AND groups.id=" + groupId + " AND NOT topics.deleted");
    }

    int count = 0;
    int pages = 0;
    int topics = tmpl.getProf().getInt("topics");

    if (rs.next()) {
      count = rs.getInt("count");
      pages = count / topics;
      if (count % topics != 0) {
        count = (pages + 1) * topics;
      }
    }
    rs.close();

    int section = group.getSectionId();
    if (section == 0) {
      throw new BadGroupException();
    }
    if (group.isLinksUp()) {
      throw new BadGroupException();
    }

    if (firstPage || offset >= pages * topics) {
      response.setDateHeader("Expires", System.currentTimeMillis() + 90 * 1000);
    } else {
      response.setDateHeader("Expires", System.currentTimeMillis() + 30 * 24 * 60 * 60 * 1000L);
    }

    if (firstPage) {
      out.print("<title>" + group.getSectionName() + " - " + group.getTitle() + " (��������� ���������)</title>");
    } else {
      out.print("<title>" + group.getSectionName() + " - " + group.getTitle() + " (��������� " + (count - offset) + '-' + (count - offset - topics) + ")</title>");
    }
%>
    <LINK REL="alternate" HREF="section-rss.jsp?section=<%= group.getSectionId() %>&amp;group=<%= group.getId()%>" TYPE="application/rss+xml">
<%
    out.print("<link rel=\"parent\" title=\"" + group.getTitle() + "\" href=\"view-section.jsp?section=" + group.getSectionId() + "\">");
%>
<%=   tmpl.DocumentHeader() %>
<form action="group.jsp">
  <table class=nav>
    <tr>
    <td align=left valign=middle>
      <a href="view-section.jsp?section=<%= group.getSectionId() %>"><%= group.getSectionName() %></a> - <strong><%= group.getTitle() %></strong>
    </td>

    <td align=right valign=middle>
      [<a href="faq.jsp">FAQ</a>]
      [<a href="rules.jsp">������� ������</a>]
<%
  User currentUser = User.getCurrentUser(db, session);

  if (group.isTopicPostingAllowed(currentUser)) {
%>
      [<a href="add.jsp?group=<%= groupId %>&amp;return=<%= URLEncoder.encode(returnUrl) %>">�������� ���������</a>]
<%
  }
%>
  [<a href="section-rss.jsp?section=<%= group.getSectionId() %>&amp;group=<%=group.getId()%>">RSS</a>]
      <select name=group onChange="submit()" title="������� �������">
<%
	Statement sectionListSt = db.createStatement();
	ResultSet sectionList = sectionListSt.executeQuery("SELECT id, title FROM groups WHERE section="+section+" order by id");

	while (sectionList.next()) {
		int id = sectionList.getInt("id");
%>
        <option value=<%= id %> <%= id==groupId?"selected":"" %> ><%= sectionList.getString("title") %></option>
<%
	}

	sectionList.close();
	sectionListSt.close();
%>
      </select>
     </td>
    </tr>
 </table>

</form>

<%
  String ignq = "";

  Map ignoreList = IgnoreList.getIgnoreListHash(db, (String) session.getValue("nick"));

  if (!showIgnored && Template.isSessionAuthorized(session) && !session.getValue("nick").equals("anonymous")) {
    if (firstPage && ignoreList != null && !ignoreList.isEmpty()) {
      ignq = " AND topics.userid NOT IN (SELECT ignored FROM ignore_list, users WHERE userid=users.id and nick='" + session.getValue("nick") + "')";
    }
  }

  out.print("<h1>");

  out.print(group.getSectionName() + ": " + group.getTitle() + "</h1>");

  if (group.getImage() != null) {
    out.print("<div align=center>");
    try {
      ImageInfo info = new ImageInfo(tmpl.getObjectConfig().getHTMLPathPrefix() + tmpl.getStyle() + group.getImage());
      out.print("<img src=\"/" + tmpl.getStyle() + group.getImage() + "\" " + info.getCode() + " border=0 alt=\"������ " + group.getTitle() + "\">");
    } catch (BadImageException ex) {
      out.print("[bad image]");
    }
    out.print("</div>");
  }

  String des = tmpl.getObjectConfig().getStorage().readMessageNull("grinfo", String.valueOf(groupId));
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
    ������ ���: <select name="showignored">
      <option value="t" <%= (showIgnored?"selected":"") %>>��� ����</option>
      <option value="f" <%= (showIgnored?"":"selected") %>>��� ������������</option>
      </select> <input type="submit" value="��������"> [<a href="ignore-list.jsp">���������</a>]
  </div>

</form>

<div class=forum>
<table width="100%" class="message-table">
<thead>
<tr><th>���������
<%
  out.print("<span style=\"font-weight: normal\">[�������: ");

  out.print("<b>���� ��������</b> <a href=\"group-lastmod.jsp?group=" + groupId + "\" style=\"text-decoration: underline\">���� ���������</a>");

  out.print("]</span>");
%></th><th>����� �������<br>�����/����/���</th></tr>
</thead>
<tbody>
<%
  String delq = showDeleted ? "" : " AND NOT deleted ";

  if (firstPage) {
    rs = st.executeQuery("SELECT topics.title as subj, lastmod, nick, topics.id as msgid, deleted, topics.stat1, topics.stat3, topics.stat4, topics.sticky FROM topics,groups,users, sections WHERE sections.id=groups.section AND (topics.moderate OR NOT sections.moderate) AND topics.userid=users.id AND topics.groupid=groups.id AND groups.id=" + groupId + delq + ignq + " AND postdate>(CURRENT_TIMESTAMP-'3 month'::interval) ORDER BY sticky desc,msgid DESC LIMIT " + topics);
  } else {
    rs = st.executeQuery("SELECT topics.title as subj, lastmod, nick, topics.id as msgid, deleted, topics.stat1, topics.stat3, topics.stat4, topics.sticky FROM topics,groups,users, sections WHERE sections.id=groups.section AND (topics.moderate OR NOT sections.moderate) AND topics.userid=users.id AND topics.groupid=groups.id AND groups.id=" + groupId + delq + " ORDER BY sticky,msgid ASC LIMIT " + topics + " OFFSET " + offset);
  }

  List outputList = new ArrayList();
  double messages = tmpl.getProf().getInt("messages");

  while (rs.next()) {
    StringBuffer outbuf = new StringBuffer();
    int stat1 = rs.getInt("stat1");

    Timestamp lastmod = rs.getTimestamp("lastmod");
    if (lastmod == null) {
      lastmod = new Timestamp(0);
    }

    outbuf.append("<tr><td>");
    if (rs.getBoolean("deleted")) {
      outbuf.append("[X] ");
    } else if (rs.getBoolean("sticky")) {
      outbuf.append("<img src=\"img/paper_clip.gif\" alt=\"�����������\" title=\"�����������\"> ");
    }

    int pagesInCurrent = (int) Math.ceil(stat1 / messages);

    if (firstPage) {
      if (pagesInCurrent <= 1) {
        outbuf.append("<a href=\"view-message.jsp?msgid=").append(rs.getInt("msgid")).append("&amp;lastmod=").append(lastmod.getTime()).append("\" rev=contents>").append(StringUtil.makeTitle(rs.getString("subj"))).append("</a>");
      } else {
        outbuf.append("<a href=\"view-message.jsp?msgid=").append(rs.getInt("msgid")).append("\" rev=contents>").append(StringUtil.makeTitle(rs.getString("subj"))).append("</a>");
      }
    } else {
      outbuf.append("<a href=\"view-message.jsp?msgid=").append(rs.getInt("msgid")).append("\" rev=contents>").append(StringUtil.makeTitle(rs.getString("subj"))).append("</a>");
    }

    if (pagesInCurrent > 1) {
      outbuf.append("&nbsp;(���.");

      for (int i = 1; i < pagesInCurrent; i++) {
        outbuf.append(" <a href=\"view-message.jsp?msgid=").append(rs.getInt("msgid"));
        if ((i == pagesInCurrent - 1) && firstPage) {
          outbuf.append("&amp;lastmod=").append(lastmod.getTime());
        }
        outbuf.append("&amp;page=").append(i).append("\">");
        outbuf.append(i + 1).append("</a>");
      }
      outbuf.append(')');
    }

    outbuf.append(" (").append(rs.getString("nick")).append(')');
    outbuf.append("</td>");

    outbuf.append("<td align=center>");
    int stat3 = rs.getInt("stat3");
    int stat4 = rs.getInt("stat4");

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

    if (!firstPage && ignoreList != null && !ignoreList.isEmpty() && ignoreList.containsValue(rs.getString("nick"))) {
      outbuf = new StringBuffer();
      //new StringBuffer().append("<tr><td colspan=2>���� ������� ������������ �������������</td></tr>");
    }

    outputList.add(outbuf.toString());
  }
  rs.close();

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
  out.print("<tr><td colspan=2><p>");

  String ignoredAdd = tmpl.getProf().getBoolean("showignored")!=showIgnored?("&amp;showignored=" + (showIgnored ? "t" : "f")):"";

  out.print("<div style=\"float: left\">");

  // �����
  if (firstPage) {
    out.print("");
  } else if (offset == pages * topics) {
    out.print("<a href=\"group.jsp?group=" + groupId + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">������</a> ");
  } else {
    out.print("<a rel=prev rev=next href=\"group.jsp?group=" + groupId + "&amp;offset=" + (offset + topics) + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">�����</a>");
  }

  out.print("</div>");

  // ������
  out.print("<div style=\"float: right\">");

  if (firstPage) {
    out.print("<a rel=next rev=prev href=\"group.jsp?group=" + groupId + "&amp;offset=" + (pages * topics) + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">�����</a>");
  } else if (offset == 0 && !firstPage) {
    out.print("<b>������</b>");
  } else {
    out.print("<a rel=next rev=prev href=\"group.jsp?group=" + groupId + "&amp;offset=" + (offset - topics) + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">������</a>");
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
        out.print("[<a href=\"group.jsp?group=" + groupId + "&amp;offset=0" + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">�����</a>] ");
      } else {
        out.print("[<b>�����</b>] ");
      }
    } else if (i==0) {
      if (firstPage) {
        out.print("[<b>������</b>] ");
      } else {
        out.print("[<a href=\"group.jsp?group=" + groupId + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">������</a>] ");
      }
    } else if ((pages + 1 - i) * topics == offset) {
      out.print("[<b>" + (pages + 1 - i) + "</b>] ");
    } else {
      out.print("[<a href=\"group.jsp?group=" + groupId + "&amp;offset=" + ((pages + 1 - i) * topics) + (showDeleted ? "&amp;deleted=t" : "") + ignoredAdd + "\">" + (pages + 1 - i) + "</a>] ");
    }
  }
%>
<p>

<% if (Template.isSessionAuthorized(session) && !showDeleted) { %>
  <hr>
  <form action="group.jsp" method=POST>
  <input type=hidden name=group value=<%= groupId %>>
  <input type=hidden name=deleted value=1>
  <% if (!firstPage) { %>
    <input type=hidden name=offset value="<%= offset %>">
  <% } %>
  <input type=submit value="�������� ��������� ���������">
  </form>
  <hr>
<% } %>

</div>
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
<%= tmpl.DocumentFooter() %>
