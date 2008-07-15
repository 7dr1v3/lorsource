<%@ page pageEncoding="koi8-r" contentType="text/html; charset=utf-8"%>
<%@ page import="java.util.Date"   %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/jsp/head.jsp"/>
<%

  response.setDateHeader("Expires", new Date(new Date().getTime() - 20 * 3600 * 1000).getTime());
  response.setDateHeader("Last-Modified", new Date(new Date().getTime() - 2 * 1000).getTime());

%>
<title>delip</title>
<link rel="parent" title="Linux.org.ru" href="/">
<jsp:include page="/WEB-INF/jsp/header.jsp"/>

<h1>�������� ��� � ���������</h1>

${message}

<br/>

������� ���: ${topics}

<ul>

  <c:forEach var="del" items="${deleted}">

    <li>
    
��������� #${del.key}: ${del.value}

    </li>
                      
  </c:forEach>
                        
</ul>

<jsp:include page="/WEB-INF/jsp/footer.jsp"/>

