<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.Connection" errorPage="/error.jsp" %>
<%@ page import="java.util.Date"%>
<%@ page import="ru.org.linux.site.*" %>
<%@ page import="ru.org.linux.util.ServletParameterParser" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<% Template tmpl = new Template(request, config, response);%>
<%= tmpl.head() %>
<%

  response.setDateHeader("Expires", new Date(new Date().getTime() - 20 * 3600 * 1000).getTime());
  response.setDateHeader("Last-Modified", new Date(new Date().getTime() - 2 * 1000).getTime());

  int sectionid = new ServletParameterParser(request).getInt("section");

  Connection db = null;
  try {
    db = LorDataSource.getConnection();

    Section section = new Section(db, sectionid);

    if (!section.isBrowsable()) {
      throw new BadSectionException(sectionid);
    }
%>
<c:set var="section" value="<%= section %>"/>
<c:set var="groups" value="<%= Group.getGroups(db, section) %>"/>

<%
  } finally {
    if (db!=null) {
      db.close();
    }
  }
%>

<title>${section.name}</title>
<link rel="parent" title="Linux.org.ru" href="/">
<LINK REL="alternate" HREF="section-rss.jsp?section=${section.id}" TYPE="application/rss+xml">
<jsp:include page="/WEB-INF/jsp/header.jsp"/>

  <table class=nav>
    <tr>
      <td align=left valign=middle>
        <strong>${section.name}</strong>
      </td>

      <td align=right valign=middle>
        [<a href="add-section.jsp?section=${section.id}">${section.addText}</a>]
        
        [<a href="tracker.jsp">��������� ���������</a>]

        <c:if test="${section.forum}">
          [<a href="rules.jsp">������� ������</a>]
        </c:if>

        [<a href="section-rss.jsp?section=${section.id}">RSS</a>]
      </td>
    </tr>
  </table>

<h1>${section.name}</h1>

������:
<ul>

  <c:forEach var="group" items="${groups}">
    <li>
      <a href="${group.url}">${group.title}</a>

      (${group.stat1}/${group.stat2}/${group.stat3})

      <c:if test="${group.info != null}">
        - <em><c:out value="${group.info}" escapeXml="false"/></em>
      </c:if>

    </li>

  </c:forEach>

</ul>

<c:if test="${section.forum}">
<h1>���������</h1>
���� �� ��� �� ������������������ - ��� <a href="register.jsp">����</a>.
<ul>
<li><a href="addphoto.jsp">�������� ����������</a>
<li><a href="register.jsp?mode=change">��������� �����������</a>
<li><a href="lostpwd.jsp">�������� ������� ������</a>
<li><a href="edit-profile.jsp">������������ ��������� �����</a>
</ul>
</c:if>

<jsp:include page="/WEB-INF/jsp/footer.jsp"/>
