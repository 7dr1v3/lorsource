<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="ru.org.linux.site.Template" errorPage="error.jsp"%>
<% Template tmpl = new Template(request, config, response); %>
<%= tmpl.head() %>
<title>� �������</title>
<%= tmpl.DocumentHeader() %>
<div class=text>

<h1>� �������</h1>
�������������� ������ <i>LINUX.ORG.RU: ������� ���������� �� �� Linux</i> ��� 
������� � ������� 
1998 ����. ����� ����� �������� �������� ��������� ��������������� ������� � 
������������ ������� Linux � ������. �� ��������� ���������� �����������
������ ��������� Linux-��������������� �����������, ���������� ���������,
��������, ������������� � ������� ���������.

<h1>���� ��������</h1>
�� ������ ������������ ��� ������ ��� ������ �� ��� ����:<p>
<img width=88 height=31 src="/img/button.gif">

<h1>�������</h1>
���������� ������� � ����������� � ���� �������� �������������� ��������� 
��� "<a href="http://www.ratel.ru">����-��������</a>".
<p>
	���������� ������� ����� ���������� ���: <a href="http://linuxhacker.ru/stats">����������</a>.

<h1>����</h1>
�� �������� �� Fedora Core 4 Linux, ���� PostgreSQL 8.0, Apache2,
Sun Java SDK 1.4, Resin. ������� ����� ������� (<b>green</b>) ��
����������������� � hardware.<p>

<H1>�������� �����</H1>
����������� ������� ���������� �� ������ <a href="mailto:webmaster@linux.org.ru">webmaster@linux.org.ru</a>. � ���������, ��-�� ��������
������ �����, � ��� ��� ����������� �������� �� ����� ������� � Linux.
������� ���� ������ � <a href="view-section.jsp?section=2">������</a>.

<h1>���� �������</h1>
������ ���������� � ����������� ������������� � ��������� ����� �������. 
<ul>
<li><a href="whois.jsp?nick=maxcom">������ ���������</a> - <i>�����������
�������</i> -
����������, ���������, ������, �������, �������������� ����������. 
<li><a href="whois.jsp?nick=ott">������� ���</a> - ������ ������������.
<li><a href="whois.jsp?nick=Tima_">����� �������</a> - �������.
<li><a href="whois.jsp?nick=green">���� ������</a> - �������, �������������.
<li><a href="whois.jsp?nick=ivlad">�������� ������</a> - �������, ������ Security ������
</ul>

</div>
<%= tmpl.DocumentFooter() %>
