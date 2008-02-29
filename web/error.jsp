<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"%>
<%@ page import="java.io.File,java.io.IOException" isErrorPage="true" %>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="java.io.StringWriter"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.logging.Logger"%>
<%@ page import="javax.mail.Session"%>
<%@ page import="javax.mail.Transport"%>
<%@ page import="javax.mail.internet.InternetAddress"%>
<%@ page import="javax.mail.internet.MimeMessage"%>
<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="com.danga.MemCached.MemCachedClient" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="ru.org.linux.boxlet.BoxletVectorRunner" %>
<%@ page import="ru.org.linux.site.*" %>
<%@ page import="ru.org.linux.storage.StorageNotFoundException" %>
<%@ page import="ru.org.linux.util.*" %>
<% Template tmpl = new Template(request, config, response);
  Logger logger = Logger.getLogger("ru.org.linux");
%>
<%= tmpl.head() %>
<title>������: <%= HTMLFormatter.htmlSpecialChars(exception.getClass().getName()) %></title>
<jsp:include page="WEB-INF/jsp/header.jsp"/>
<h1><%=exception.getMessage()==null?HTMLFormatter.htmlSpecialChars(exception.getClass().getName()):HTMLFormatter.htmlSpecialChars(exception.getMessage()) %></h1>

<% if (exception instanceof UserErrorException) { %>
<% } else if (exception instanceof ScriptErrorException || exception instanceof ServletParameterException) { %>
�������, ������������� ��������� ���� �������� ������������
���������. ���� �� ��� ��������� ��� ������� ���� ��
������� ������ �����, ����������
<a href="mailto:bugs@linux.org.ru">��������</a> ��� ������
������� � ����������� �������.
<% } else { %>

� ���������, ��������� �������������� �������� ��� ��������� ��������. ����
�� ��������, ��� ��� �������� �� ������� ����� ������, ���������� <a href="mailto:bugs@linux.org.ru">��������</a> ��� � ������ � �������� �� �������������. �� ��������
����� ������� ������ URL ���������, ��������� ����������.
<%

  String email = "bugs@linux.org.ru";

  InternetAddress mail = new InternetAddress(email);
  StringBuffer text = new StringBuffer();

  if (exception.getMessage()==null) {
    text.append(exception.getClass().getName());
  } else {
    text.append(exception.getMessage());
  }
  text.append("\n\n");
  text.append("Main URL: ").append(tmpl.getMainUrl()).append("\n");
  text.append("Req. URI: ").append(request.getAttribute("javax.servlet.error.request_uri")).append("\n");
  text.append(" Headers: ");
  Enumeration enu = request.getHeaderNames();
  while ( enu.hasMoreElements() ) {
    String paramName = (String) enu.nextElement();
    text.append("\n         ").append(paramName).append(": ").append(request.getHeader(paramName));
  }
  text.append("\n\n");

  StringWriter exceptionStackTrace = new StringWriter();
  exception.printStackTrace(new PrintWriter(exceptionStackTrace));
  text.append(exceptionStackTrace.toString());

  Properties props = new Properties();
  props.put("mail.smtp.host", "localhost"); 
  Session mailSession = Session.getDefaultInstance(props, null);

  MimeMessage emailMessage = new MimeMessage(mailSession);
  emailMessage.setFrom(new InternetAddress("no-reply@linux.org.ru"));

  emailMessage.addRecipient(MimeMessage.RecipientType.TO, mail);
  emailMessage.setSubject("Linux.org.ru error");
  emailMessage.setSentDate(new Date());
  emailMessage.setText(text.toString(), "UTF-8");
  
  out.println("\n<br>\n<br>");
  
  try {
    Transport.send(emailMessage);
    out.println("<b>��������� ������������� ������. �������������� �������� �� ���� ������.</b>");
  } catch(Exception e) {
    out.println("<b>��������� ������������� ������. � ��������� ������ �������� �� ��������� ��������� �� �������.</b>");
  }
  logger.severe(exception.toString()+": "+StringUtil.getStackTrace(exception));
%>
<% } %>

<jsp:include page="WEB-INF/jsp/footer.jsp"/>
