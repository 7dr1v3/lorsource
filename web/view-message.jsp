<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="java.sql.Connection,java.sql.Statement,java.sql.Timestamp,javax.servlet.http.HttpServletResponse,ru.org.linux.site.*,ru.org.linux.util.StringUtil" errorPage="/error.jsp" buffer="200kb"%>
<% Template tmpl = new Template(request, config, response); %>
<%= tmpl.head() %>
<%
  Connection db = null;

  try {
    int msgid = tmpl.getParameters().getInt("msgid");

    String mainurl = "view-message.jsp?msgid=" + msgid;

    boolean showDeleted = request.getParameter("deleted") != null;

    int filterMode = CommentViewer.FILTER_NONE;

    if (!tmpl.getProf().getBoolean("showanonymous")) {
      filterMode += CommentViewer.FILTER_ANONYMOUS;
    }

    if (!tmpl.getProf().getBoolean("showignored")) {
      filterMode += CommentViewer.FILTER_IGNORED;
    }

    db = tmpl.getConnection("view-message");

    String nick = Template.getNick(session);

    if (nick == null || IgnoreList.getIgnoreListHash(db, nick).isEmpty()) {
      filterMode = filterMode & ~CommentViewer.FILTER_IGNORED;
    }

    int defaultFilterMode = filterMode;

    if (request.getParameter("filter") != null) {
      filterMode = CommentViewer.parseFilterChain(request.getParameter("filter"));
    }

    Statement st = db.createStatement();

    if (showDeleted && !"POST".equals(request.getMethod())) {
      response.setHeader("Location", tmpl.getMainUrl() + "view-message.jsp?msgid=" + msgid);
      response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);

      showDeleted = false;
    }

    if (showDeleted) {
      if (!tmpl.isSessionAuthorized(session)) {
        throw new BadInputException("�� ��� ����� �� �������");
      }
    }

    int npage = 0;
    if (request.getParameter("page") != null) {
      npage = tmpl.getParameters().getInt("page");
    }

    if (showDeleted) {
      npage = -1;
    }

    Message message = new Message(db, msgid);

    if (message.isExpired() && showDeleted) {
      throw new AccessViolationException("������ ���������� ��������� ����������� � ���������� �����");
    }
    if (message.isExpired() && message.isDeleted()) {
      throw new AccessViolationException("������ ���������� ���������� ��������� ���������");
    }
    if (message.isDeleted() && !tmpl.isSessionAuthorized(session)) {
      throw new AccessViolationException("��������� �������");
    }

    out.print("<title>" + message.getPortalTitle() + " - " + message.getGroupTitle() + " - " + message.getTitle() + "</title>");
    out.print("<link rel=\"parent\" title=\"" + message.getPortalTitle() + " - " + message.getGroupTitle() + "\" href=\"group.jsp?group=" + message.getGroupId() + "\">");

// count last modified time
    if (!tmpl.isDebugMode() && !message.isDeleted() && !showDeleted && message.getLastModified() != null) {
      response.setDateHeader("Last-Modified", message.getLastModified().getTime());
    }

    if (message.isExpired()) {
      response.setDateHeader("Expires", System.currentTimeMillis() + 30 * 24 * 60 * 60 * 1000L);
    } else {
      response.setDateHeader("Expires", System.currentTimeMillis() - 24 * 60 * 60 * 1000);
    }

    Message prevMessage = message.getPreviousMessage(db);
    Message nextMessage = message.getNextMessage(db);

    if (prevMessage != null) {
      out.print("<link rel=\"Previous\" href=\"view-message.jsp?msgid=" + prevMessage.getMessageId() + "&amp;lastmod=" + prevMessage.getLastModified().getTime() + "\" title=\"" + StringUtil.makeTitle(prevMessage.getTitle()) + "\">");
    }

    if (nextMessage != null) {
      out.print("<link rel=\"Next\" href=\"view-message.jsp?msgid=" + nextMessage.getMessageId() + "&amp;lastmod=" + nextMessage.getLastModified().getTime() + "\" title=\"" + StringUtil.makeTitle(nextMessage.getTitle()) + "\">");
    }
%>
<LINK REL="alternate" TITLE="L.O.R RSS" HREF="topic-rss.jsp?topic=<%= msgid %>" TYPE="application/rss+xml">
<%= tmpl.DocumentHeader() %>

<div class=messages>

<%
  int scroll = Section.getScrollMode(message.getSectionId());

  if (scroll != Section.SCROLL_NOSCROLL) {
%>
    <table class=nav>
      <tr>
<%
  if (scroll == Section.SCROLL_GROUP) {
    out.print("<td align=left valign=middle width=\"35%\"><table><tr valign=middle><td>");

    if (prevMessage != null) {
      Timestamp lastmod = prevMessage.getLastModified();

      out.print("<a href=\"view-message.jsp?msgid=" + prevMessage.getMessageId() + "&amp;lastmod=" + lastmod.getTime() + "\" rel=prev rev=next>&lt;&lt;&lt;</a></td><td align=left valign=top>" + StringUtil.makeTitle(prevMessage.getTitle()));
    }

    out.print("</td></table></td>");

    out.print("<td align=center valign=middle><table><tr valign=middle><td><a title=\"" + message.getPortalTitle() + " - " + message.getGroupTitle() + "\" href=\"group.jsp?group=" + message.getGroupId() + "\">" + message.getPortalTitle() + " - " + message.getGroupTitle() + "</a></td></tr></table>");

    out.print("<td align=left valign=middle width=\"35%\"><table width=\"100%\"><tr valign=middle align=right><td>");

    if (nextMessage != null) {
      Timestamp lastmod = nextMessage.getLastModified();

      out.print(StringUtil.makeTitle(nextMessage.getTitle()) + "</td><td align=right valign=middle><a href=\"view-message.jsp?msgid=" + nextMessage.getMessageId() + "&amp;lastmod=" + lastmod.getTime() + "\" rev=prev rel=next>&gt;&gt;&gt;</a>");
    }

    out.print("</td></table></td>");
  } else if (scroll == Section.SCROLL_SECTION) {
    out.print("<td align=left valign=middle width=\"35%\"><table width=\"100%\"><tr valign=middle><td>");

    if (prevMessage != null) {
      Timestamp lastmod = prevMessage.getLastModified();
      if (lastmod == null) lastmod = new Timestamp(0);

      out.print("<a href=\"view-message.jsp?msgid=" + prevMessage.getMessageId() + "&amp;lastmod=" + lastmod.getTime() + "\" rel=prev rev=next>&lt;&lt;&lt;</a></td><td align=left valign=top>" + StringUtil.makeTitle(prevMessage.getTitle()) + " (" + prevMessage.getGroupTitle() + ')');
    }

    out.print("</td></table></td>");

    out.print("<td align=center valign=middle><table><tr valign=middle><td><a title=\"" + message.getPortalTitle() + " - " + message.getGroupTitle() + "\" href=\"group.jsp?group=" + message.getGroupId() + "\">" + message.getPortalTitle() + " - " + message.getGroupTitle() + "</a></td></tr></table>");

    out.print("<td align=left valign=middle width=\"35%\"><table width=\"100%\"><tr valign=middle align=right><td>");
    if (nextMessage != null) {
      Timestamp lastmod = nextMessage.getLastModified();
      if (lastmod == null) lastmod = new Timestamp(0);

      out.print(StringUtil.makeTitle(nextMessage.getTitle()) + " (" + nextMessage.getGroupTitle() + ")</td><td valign=middle align=right><a href=\"view-message.jsp?msgid=" + nextMessage.getMessageId() + "&amp;lastmod=" + lastmod.getTime() + "\" rev=prev rel=next>&gt;&gt;&gt;</a>");
    }

    out.print("</td></table></td>");
  }
%>
      </tr>
    </table>
<%
   }
%>

<h1>
<% if (showDeleted) out.print("<br>����� ������ ��������� ������������"); %>
</h1>

<%
  boolean comment = message.isCommentEnabled();
  int messages = tmpl.getProf().getInt("messages");
  int pages = message.getPageCount(messages);

  String pageInfo = null;
  if (pages > 1) {
    StringBuffer bufInfo = new StringBuffer();

    bufInfo.append("[��������");

    String linkurl = mainurl;

    for (int i = 0; i < pages; i++) {
      bufInfo.append(' ');

      if (i==pages-1) {
        linkurl += "&amp;lastmod="+message.getLastModified().getTime();
      }

      if (i != npage) {
        if (i>0) {
          bufInfo.append("<a href=\"").append(linkurl).append("&amp;page=").append(i);
        } else {
          bufInfo.append("<a href=\"").append(linkurl);
        }

        if (filterMode!=defaultFilterMode) {
          bufInfo.append("&filter=").append(CommentViewer.toString(filterMode));
        }

        bufInfo.append("\">").append(i + 1).append("</a>");
      } else {
        bufInfo.append("<strong>").append(i + 1).append("</strong>");
      }
    }

    if (Template.isSessionAuthorized(session)) {
      if (npage!=-1) {
        bufInfo.append(" <a href=\"").append(linkurl).append("&amp;page=-1").append("\">���").append("</a>");
      } else {
        bufInfo.append(" <strong>���").append("</strong>");      
      }
    }

    bufInfo.append(']');
    pageInfo = bufInfo.toString();
  }

  if (request.getParameter("highlight") != null) {
    out.print(message.printMessage(tmpl, db, true, Template.getNick(session), tmpl.getParameters().getInt("highlight")));
  } else {
    out.print(message.printMessage(tmpl, db, true, Template.getNick(session)));
  }
%>

<% if (!Template.isSessionAuthorized(session)) { %>
<div style="text-align: center; margin-top: 1em">
<script type="text/javascript"><!--
google_ad_client = "pub-6069094673001350";
google_ad_width = 728;
google_ad_height = 90;
google_ad_format = "728x90_as";
google_ad_type = "text_image";
//2007-06-29: lor-messages
google_ad_channel = "0949716006";
google_color_border = "808080";
google_color_bg = "000030";
google_color_link = "FFFFFF";
google_color_text = "C8C8C8";
google_color_url = "999999";
google_ui_features = "rc:0";
//-->
</script>
<script type="text/javascript"
  src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div><br>
<% } %>

<%
  if (comment) {
    if (tmpl.getProf().getBoolean("sortwarning")) {
      out.print("<div class=nav>");

      if (tmpl.getProf().getBoolean("newfirst"))
        out.print("��������� ������������� � ������� �������� ���� �� ���������");
      else
        out.print("��������� ������������� � ������� ����������� ���� �� ���������");

      out.print("</div>");
    }

    if (!showDeleted /* && message.getCommentCount() > 0 */) {
      out.print("<form method=\"GET\" action=\"view-message.jsp\">");
      out.print("<div class=nav>");

      out.print("<input type=hidden name=msgid value=\"" + msgid + "\">");
      if (npage != 0) {
        out.print("<input type=hidden name=page value=\"" + npage + "\">");
      }
      out.print("������ ������������: <select name=\"filter\">");
      out.print("<option value=\"" + CommentViewer.toString(CommentViewer.FILTER_NONE) + "\"" + (filterMode == CommentViewer.FILTER_NONE ? " selected=\"selected\"" : "") + ">��� �����������</option>");
      out.print("<option value=\"" + CommentViewer.toString(CommentViewer.FILTER_ANONYMOUS) + "\"" + (filterMode == CommentViewer.FILTER_ANONYMOUS ? " selected=\"selected\"" : "") + ">��� ���������</option>");

      if (!tmpl.isUsingDefaultProfile()) {
        out.print("<option value=\"" + CommentViewer.toString(CommentViewer.FILTER_IGNORED) + "\"" + (filterMode == CommentViewer.FILTER_IGNORED ? " selected=\"selected\"" : "") + ">��� ������������</option>");
        out.print("<option value=\"" + CommentViewer.toString(CommentViewer.FILTER_LISTANON) + "\"" + (filterMode == CommentViewer.FILTER_LISTANON ? " selected=\"selected\"" : "") + ">��� ��������� � ������������</option>");
      }

      out.print("</select>");
      out.print(" <input type=\"submit\" value=\"��������\">");

      if (!tmpl.isUsingDefaultProfile()) {
        out.print(" [<a href=\"ignore-list.jsp\">���������</a>]");
      }

      out.print(" [<a href=\"topic-rss.jsp?topic="+ msgid +"\">RSS</a>]");

      out.print("</div>");
      out.print("</form>");
    }

    if (pageInfo != null) {
      out.print("<div class=\"pageinfo\">");
      out.print(pageInfo);
      out.print("</div>");
    }

    out.print("<div class=comment>");

    int offset = 0;
    int limit = 0;
    boolean reverse = tmpl.getProf().getBoolean("newfirst");

    if (npage != -1) {
      limit = messages;
      offset = messages * npage;
    }

    CommentList comments = CommentList.getCommentList(db, message, showDeleted);

    CommentViewer cv = new CommentViewer(tmpl, db, comments, Template.getNick(session), message.isExpired());

    if (filterMode != CommentViewer.FILTER_NONE) {
      out.print(cv.showFiltered(db, reverse, offset, limit, filterMode, Template.getNick(session)));
    } else {
      out.print(cv.showAll(reverse, offset, limit));
    }

    out.print("</div>");

    if (pageInfo != null) {
      out.print("<div class=pageinfo>");
      out.print(pageInfo);
      out.print("</div>");
    }
  }
%>
<%
  if (scroll != Section.SCROLL_NOSCROLL) {
    out.print("<table class=nav><tr>");

    if (scroll == Section.SCROLL_GROUP) {
      out.print("<td align=left valign=middle width=\"35%\"><table><tr valign=middle><td>");

      if (prevMessage != null) {
        Timestamp lastmod = prevMessage.getLastModified();

        out.print("<a href=\"view-message.jsp?msgid=" + prevMessage.getMessageId() + "&amp;lastmod=" + lastmod.getTime() + "\" rel=prev rev=next>&lt;&lt;&lt;</a></td><td align=left valign=top>" + StringUtil.makeTitle(prevMessage.getTitle()));
      }

      out.print("</td></table></td>");

      out.print("<td align=center valign=middle><table><tr valign=middle><td><a title=\"" + message.getPortalTitle() + " - " + message.getGroupTitle() + "\" href=\"group.jsp?group=" + message.getGroupId() + "\">" + message.getPortalTitle() + " - " + message.getGroupTitle() + "</a></td></tr></table>");

      out.print("<td align=left valign=middle width=\"35%\"><table width=\"100%\"><tr valign=middle align=right><td>");

      if (nextMessage != null) {
        Timestamp lastmod = nextMessage.getLastModified();

        out.print(StringUtil.makeTitle(nextMessage.getTitle()) + "</td><td align=right valign=middle><a href=\"view-message.jsp?msgid=" + nextMessage.getMessageId() + "&amp;lastmod=" + lastmod.getTime() + "\" rev=prev rel=next>&gt;&gt;&gt;</a>");
      }

      out.print("</td></table></td>");
    } else if (scroll == Section.SCROLL_SECTION) {
      out.print("<td align=left valign=middle width=\"35%\"><table width=\"100%\"><tr valign=middle><td>");

      if (prevMessage != null) {
        Timestamp lastmod = prevMessage.getLastModified();
        if (lastmod == null) lastmod = new Timestamp(0);

        out.print("<a href=\"view-message.jsp?msgid=" + prevMessage.getMessageId() + "&amp;lastmod=" + lastmod.getTime() + "\" rel=prev rev=next>&lt;&lt;&lt;</a></td><td align=left valign=top>" + StringUtil.makeTitle(prevMessage.getTitle()) + " (" + prevMessage.getGroupTitle() + ')');
      }

      out.print("</td></table></td>");

      out.print("<td align=center valign=middle><table><tr valign=middle><td><a title=\"" + message.getPortalTitle() + " - " + message.getGroupTitle() + "\" href=\"group.jsp?group=" + message.getGroupId() + "\">" + message.getPortalTitle() + " - " + message.getGroupTitle() + "</a></td></tr></table>");

      out.print("<td align=left valign=middle width=\"35%\"><table width=\"100%\"><tr valign=middle align=right><td>");
      if (nextMessage != null) {
        Timestamp lastmod = nextMessage.getLastModified();
        if (lastmod == null) lastmod = new Timestamp(0);

        out.print(StringUtil.makeTitle(nextMessage.getTitle()) + " (" + nextMessage.getGroupTitle() + ")</td><td valign=middle align=right><a href=\"view-message.jsp?msgid=" + nextMessage.getMessageId() + "&amp;lastmod=" + lastmod.getTime() + "\" rev=prev rel=next>&gt;&gt;&gt;</a>");
      }

      out.print("</td></table></td>");
    }
    out.print("</tr></table>");
  }
%>



</div>

<% if (tmpl.isSessionAuthorized(session) && !message.isExpired() && !showDeleted) { %>
<hr>
<form action="view-message.jsp" method=POST>
<input type=hidden name=msgid value=<%= msgid %>>
<input type=hidden name=deleted value=1>
<input type=submit value="�������� ��������� �����������">
</form>
<hr>
<% } %>

<p>
<i>
<% String masterUrl = "http://www.linux.org.ru/view-message.jsp?msgid="+msgid; %>
����������, ��� ������ �� ��������� ����������� URL: <br>
<a href="<%= masterUrl %>"><%= masterUrl %></a></i>
<p>
<i>��������� ���������� ���������: <%= Template.dateFormat.format(message.getLastModified()) %> </i>

<%
   st.close();

  } finally {
    if (db!=null) db.close();
  }
%>
<%=	tmpl.DocumentFooter() %>
