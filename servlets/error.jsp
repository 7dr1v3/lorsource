<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="ru.org.linux.site.ScriptErrorException,ru.org.linux.site.Template" isErrorPage="true" %>
<%@ page import="ru.org.linux.site.UserErrorException"%>
<%@ page import="ru.org.linux.util.HTMLFormatter"%>
<%@ page import="ru.org.linux.util.ServletParameterException"%>
<%@ page import="ru.org.linux.util.StringUtil"%>
<% Template tmpl = new Template(request, config, response, true); %>
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
  tmpl.getLogger().error("exception", exception.toString()+": "+StringUtil.getStackTrace(exception));
%>
<% } %>

<%= tmpl.DocumentFooter() %>
