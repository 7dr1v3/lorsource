<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"%>
<%@ page import="java.sql.Connection,java.sql.PreparedStatement, java.sql.ResultSet, java.sql.Statement, java.util.Date, java.util.List, javax.servlet.http.Cookie"  %>
<%@ page import="javax.servlet.http.HttpServletResponse"%>
<%@ page import="ru.org.linux.boxlet.BoxletVectorRunner"%>
<%@ page import="ru.org.linux.site.*" %>
<%@ page import="ru.org.linux.util.ServletParameterParser" %>
<% Template tmpl = Template.getTemplate(request); %>
<jsp:include page="WEB-INF/jsp/head.jsp"/>

<%
  Connection db = null;

  try {
    db = LorDataSource.getConnection();
    db.setAutoCommit(false);
    String nick = request.getParameter("nick");
    if (nick == null || "".equals(nick)) {
      throw new BadInputException("�� ������ nick");
    }

    User user = User.getUser(db, nick);

    if (!user.isActivated()) {
      String activation = request.getParameter("activate");

      if (activation == null) {
        throw new AccessViolationException("Not activated");
      }

      String regcode = user.getActivationCode(tmpl.getSecret());

      if (regcode.equals(activation)) {
        PreparedStatement pst = db.prepareStatement("UPDATE users SET activated='t' WHERE id=?");
        pst.setInt(1, user.getId());
        pst.executeUpdate();
      } else {
        throw new AccessViolationException("Bad activation code");
      }
    }

    user.checkAnonymous();
    user.checkPassword(request.getParameter("passwd"));

    if (session == null) {
      throw new BadInputException("�� ������� ������� ������; �������� ����������� ��������� Cookie");
    }

    session.putValue("login", Boolean.TRUE);
    session.putValue("nick", nick);
    session.putValue("moderator", user.canModerate());

    Cookie cookie = new Cookie("password", user.getMD5(tmpl.getSecret()));
    cookie.setMaxAge(60 * 60 * 24 * 31 * 24);
    cookie.setPath("/");
    response.addCookie(cookie);

    Cookie prof = new Cookie("profile", nick);
    prof.setMaxAge(60 * 60 * 24 * 31 * 12);
    prof.setPath("/");
    response.addCookie(prof);

    user.acegiSecurityHack(response, session);

    response.setHeader("Location", tmpl.getMainUrl());
    response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);

    User.updateUserLastlogin(db, nick, new Date());

    db.commit();
%>
<title>Login</title>
<jsp:include page="WEB-INF/jsp/header.jsp"/>

<h1>���� ������ �������</h1>

<strong>��������:</strong>
<ul>
<li>���� �������� ������� ������ � ��� ������, ���� � ��� ��������
��������� Cookies � ��������
<li>����������, �� ��������� ������� <em>Logout</em> ��� ������
</ul>
<%
  } finally {
    if (db!=null) {
      db.close();
    }
  }
%>
<jsp:include page="WEB-INF/jsp/footer.jsp"/>
