<%@ page contentType="text/html; charset=utf-8" pageEncoding="koi8-r"%>
<jsp:include page="WEB-INF/jsp/head.jsp"/>

<title>���������</title>
<jsp:include page="WEB-INF/jsp/header.jsp"/>
<h1>���������</h1>

<form method=POST action="login.jsp">
  <table>
    <tr>
      <td>Nick:</td>
      <td><input type=text name=nick></td>
    </tr>

    <tr>
      <td>������:</td>
      <td><input type=password name=passwd></td>
    </tr>

    <tr>
      <td>��� ����������:</td>
      <td><input type=text name=activate></td>
    </tr>

  </table>

  <input type=submit value="������������">
</form>

<jsp:include page="WEB-INF/jsp/footer.jsp"/>
