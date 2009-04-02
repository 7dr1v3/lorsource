<%@ page contentType="text/html; charset=utf-8" import="java.sql.Connection,org.apache.commons.lang.StringUtils"  %>
<%@ page import="ru.org.linux.site.*"%>
<%@ page import="ru.org.linux.spring.AddMessageForm"%>
<%@ page import="ru.org.linux.util.HTMLFormatter" %>
<%--
  ~ Copyright 1998-2009 Linux.org.ru
  ~    Licensed under the Apache License, Version 2.0 (the "License");
  ~    you may not use this file except in compliance with the License.
  ~    You may obtain a copy of the License at
  ~
  ~        http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~    Unless required by applicable law or agreed to in writing, software
  ~    distributed under the License is distributed on an "AS IS" BASIS,
  ~    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  ~    See the License for the specific language governing permissions and
  ~    limitations under the License.
  --%>

<% Template tmpl = Template.getTemplate(request);%>
<jsp:include page="/WEB-INF/jsp/head.jsp"/>
<%@ taglib tagdir="/WEB-INF/tags" prefix="lor" %>

<%
  Connection db = null;

  try {
    db = LorDataSource.getConnection();
    
    Exception error = (Exception) request.getAttribute("error");
    Message previewMsg = (Message) request.getAttribute("message");
    AddMessageForm form = (AddMessageForm) request.getAttribute("form");
    Group group = (Group) request.getAttribute("group");

    boolean preview = previewMsg!=null;

    String mode = form.getMode();
    boolean autourl = form.isAutourl();

%>

<title>Добавить сообщение</title>
  <jsp:include page="/WEB-INF/jsp/header.jsp"/>

<%
  if (form.getNoinfo() == null || !"1".equals(form.getNoinfo())) {
    out.print(request.getAttribute("addportal"));
  }
%>
<% if (preview && previewMsg!=null) { %>
<h1>Предпросмотр</h1>
<div class=messages>
  <lor:message db="<%= db %>" message="<%= previewMsg %>" showMenu="false" user="<%= Template.getNick(session) %>"/>
</div>
<% } %>
<% if (error==null) { %>
<h1>Добавить</h1>
<% } else { out.println("<h1>Ошибка: "+error.getMessage()+"</h1>"); } %>
<%--<% if (tmpl.getProf().getBoolean("showinfo") && !Template.isSessionAuthorized(session)) { %>--%>
<%--<font size=2>Чтобы просто поместить сообщение, используйте login `anonymous',--%>
<%--без пароля. Если вы собираетесь активно участвовать в форуме,--%>
<%--помещать новости на главную страницу,--%>
<%--<a href="register.jsp">зарегистрируйтесь</a></font>.--%>
<%--<p>--%>
<%--<% } %>--%>

<% if (group.isImagePostAllowed()) { %>
<p>
  Технические требования к изображению:
  <ul>
    <li>Ширина x Высота: от 400x400 до 2048x2048 пикселей</li>
    <li>Тип: jpeg, gif, png</li>
    <li>Размер не более 300 Kb</li>
  </ul>
</p>
<%   } %>
<form method=POST action="add.jsp" <%= group.isImagePostAllowed()?"enctype=\"multipart/form-data\"":"" %> >
  <input type="hidden" name="session" value="<%= HTMLFormatter.htmlSpecialChars(session.getId()) %>">
<%  if (form.getNoinfo()!=null) {
  %>
  <input type="hidden" name="noinfo" value="<%= form.getNoinfo() %>">
 <% }
%>
<% if (!tmpl.isSessionAuthorized()) { %>
Имя:
<input type=text name=nick value="<%= form.getNick()==null?"anonymous":HTMLFormatter.htmlSpecialChars(form.getNick()) %>" size=40><br>
Пароль:
<input type=password name=password size=40><br>
<% } %>
<input type=hidden name=group value="<%= form.getGuid() %>">

<% if (form.getReturnUrl()!=null) { %>
<input type=hidden name=return value="<%= HTMLFormatter.htmlSpecialChars(form.getReturnUrl()) %>">
<% } %>

Заглавие:
<input type=text name=title size=40 value="<%= form.getTitle()==null?"":HTMLFormatter.htmlSpecialChars(form.getTitle()) %>" ><br>

  <% if (group.isImagePostAllowed()) { %>
  Изображение:
  <input type="file" name="image"><br>
  <% } %>

Сообщение:<br>
<font size=2>(В режиме <i>Tex paragraphs</i> игнорируются переносы строк.<br> Пустая строка (два раза Enter) начинает новый абзац)</font><br>
<font size="2"><b>Внимание:</b> Новый экспериментальный режим - <a href="/wiki/en/Lorcode">LORCODE</a></font><br>
<textarea name=msg cols=70 rows=20><%
    if (form.getMsg()!=null) {
      out.print(HTMLFormatter.htmlSpecialChars(form.getMsg()));
    }
  %></textarea><br>

<% if (group.isLinksAllowed()) { %>
Текст ссылки:
<input type=text name=linktext size=60 value="<%= form.getLinktext()==null?group.getDefaultLinkText():HTMLFormatter.htmlSpecialChars(form.getLinktext()) %>"><br>
Ссылка (не забудьте <b>http://</b>)
<input type=text name=url size=70 value="<%= form.getUrl()==null?"":HTMLFormatter.htmlSpecialChars(form.getUrl()) %>"><br>
<% } %>
<% if (group.getSectionId()==1) { %>
Метки (разделенные запятой) 
<input type=text name=tags id="tags" size=70 value="<%= form.getTags()==null?"":StringUtils.strip(form.getTags()) %>"><br>
  Популярные теги: <%= Tags.getEditTags(Tags.getTopTags(db)) %> <br>
<% } %>
<select name=mode>
<option value=tex <%= (preview && "tex".equals(mode))?"selected":""%> >TeX paragraphs
<option value=ntobr <%= (preview && "ntobr".equals(mode))?"selected":""%> >User line break
<option value=lorcode <%= (preview && "lorcode".equals(mode))?"selected":""%> >LORCODE
</select>

<select name=autourl>
<option value=1 <%= (preview && autourl)?"selected":""%> >Auto URL
<option value=0 <%= (preview && !autourl)?"selected":""%> >No Auto URL
</select>

  <lor:captcha/>
<br>
<input type=submit value="Поместить">
<input type=submit name=preview value="Предпросмотр">
</form>
<%
  } finally {
    if (db!=null) {
      db.close();
    }
  }
%>
<jsp:include page="/WEB-INF/jsp/footer.jsp"/>
