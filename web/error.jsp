<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"%>
<%@ page import="java.util.logging.Logger,ru.org.linux.site.ScriptErrorException" isErrorPage="true" %>
<%@ page import="ru.org.linux.site.Template"%>
<%@ page import="ru.org.linux.site.UserErrorException"%>
<%@ page import="ru.org.linux.util.HTMLFormatter"%>
<%@ page import="ru.org.linux.util.ServletParameterException"%>
<%@ page import="ru.org.linux.util.StringUtil" %>
<% Template tmpl = new Template(request, config, response);
  Logger logger = Logger.getLogger("ru.org.linux");
%>
<%= tmpl.head() %>
<title>������: <%= HTMLFormatter.htmlSpecialChars(exception.getClass().getName()) %></title>
<%= tmpl.DocumentHeader() %>

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

<pre>
<%= HTMLFormatter.htmlSpecialChars(StringUtil.getStackTrace(exception)) %>
</pre>
<%
  logger.severe(exception.toString()+": "+StringUtil.getStackTrace(exception));
%>
<% } %>

<%= tmpl.DocumentFooter() %>
