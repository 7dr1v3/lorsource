<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="java.sql.*,java.util.Random,java.util.logging.Logger,javax.servlet.http.Cookie,javax.servlet.http.HttpServletResponse,ru.org.linux.site.*" errorPage="/error.jsp"%>
<%@ page import="ru.org.linux.util.HTMLFormatter"%>
<%@ page import="ru.org.linux.util.UtilBadHTMLException" %>
<%@ page import="ru.org.linux.util.UtilBadURLException" %>
<% Template tmpl = new Template(request, config, response);%>
<%
  Logger logger = Logger.getLogger("ru.org.linux");

  int topicId = tmpl.getParameters().getInt("topic");
  boolean showform = request.getParameter("msg") == null;

  if (!"POST".equals(request.getMethod()))
    showform = true;
%>
<%= tmpl.head() %>

<%
  Connection db = null;
  try {
%>

<% Exception error = null;
  if (!showform) { // add2
    String returnUrl = request.getParameter("return");
    String msg = request.getParameter("msg");
    int replyto = 0;

    if (request.getParameter("replyto") != null) {
      replyto = tmpl.getParameters().getInt("replyto");
    }

    if (!session.getId().equals(request.getParameter("session"))) {
      logger.info("Flood protection (session variable differs: " + session.getId() + ") " + request.getRemoteAddr());
      throw new BadInputException("���� ����������");
    }

    try {
      if (returnUrl == null) {
        returnUrl = "";
      }

      String title = request.getParameter("title");
      if (title == null) {
        title = "";
      }

      title = HTMLFormatter.htmlSpecialChars(title);
      if ("".equals(title)) {
        throw new BadInputException("��������� ��������� �� ����� ���� ������");
      }

      if ("".equals(msg)) {
        throw new BadInputException("����������� �� ����� ���� ������");
      }

      boolean autourl = tmpl.getParameters().getBoolean("autourl");

      if (!Template.isSessionAuthorized(session)) {
        CaptchaSingleton.checkCaptcha(session, request);
      }

      // prechecks is over

      db = tmpl.getConnection("add_comment");
      db.setAutoCommit(false);
      IPBlockInfo.checkBlockIP(db, request.getRemoteAddr());

      User user;

      if (!Template.isSessionAuthorized(session)) {
        if (request.getParameter("nick") == null) {
          throw new BadInputException("�� ��� ����� �� �������");
        }
        user = new User(db, request.getParameter("nick"));
        user.checkPassword(request.getParameter("password"));
      } else {
        user = new User(db, (String) session.getAttribute("nick"));
        user.checkBlocked();
      }

      if (user.isAnonymous()) {
        if (msg.length() > 4096) {
          throw new BadInputException("������� ������� ���������");
        }
      } else {
        if (msg.length() > 8192) {
          throw new BadInputException("������� ������� ���������");
        }
      }

      Cookie nickCookie = new Cookie("NickCookie", user.getNick());
      nickCookie.setMaxAge(60 * 60 * 24 * 31 * 24);
      nickCookie.setPath("/");
      response.addCookie(nickCookie);

      if (replyto != 0) {
        Comment reply = new Comment(db, replyto);
        if (reply.isDeleted()) {
          throw new AccessViolationException("����������� ��� ������");
        }

        if (reply.getTopic() != topicId) {
          throw new AccessViolationException("������������ ����?!");
        }
      }

      Statement st = db.createStatement();
      Message topic = new Message(db, topicId);

      int postscore = topic.getPostScore();

      if (postscore != 0) {
        if (user.getScore() < postscore || user.isAnonymous()) {
          throw new AccessViolationException("�� �� ������ ��������� ����������� � ��� ����");
        }
      }

      String mode = tmpl.getParameters().getString("mode");

      if (topic.isDeleted()) {
        throw new AccessViolationException("������ ��������� ����������� � ���������� ���������");
      }
      if (!topic.isCommentEnabled()) {
        throw new AccessViolationException("� ��� ������ ������ ��������� �����������");
      }

      int maxlength = 80; // TODO: remove this hack
      HTMLFormatter form = new HTMLFormatter(msg);
      form.setMaxLength(maxlength);
      if ("pre".equals(mode)) {
        form.enablePreformatMode();
      }
      if (autourl) {
        form.enableUrlHighLightMode();
      }
      if ("ntobr".equals(mode)) {
        form.enableNewLineMode();
      }
      if ("tex".equals(mode)) {
        form.enableTexNewLineMode();
      }
      if ("quot".equals(mode)) {
        form.enableTexNewLineMode();
        form.enableQuoting();
      }

      form.enablePlainTextMode();

      try {
        msg = form.process();
      } catch (UtilBadHTMLException e) {
        throw new BadInputException(e);
      }

      // section EXPIRE
      if (topic.isExpired()) {
        throw new AccessViolationException("������ ��� ��������");
      }

      DupeProtector.getInstance().checkDuplication(request.getRemoteAddr());

      // allocation MSGID
      ResultSet rs = st.executeQuery("select nextval('s_msgid') as msgid");
      rs.next();
      int msgid = rs.getInt("msgid");

      // insert headers
      PreparedStatement pst = db.prepareStatement("INSERT INTO comments (id, userid, title, postdate, replyto, deleted, topic, postip) VALUES (?, ?, ?, CURRENT_TIMESTAMP, ?, 'f', ?, '" + request.getRemoteAddr() + "')");
      pst.setInt(1, msgid);
      pst.setInt(2, user.getId());
      pst.setString(3, title);
      pst.setInt(5, topicId);

      if (replyto != 0) {
        pst.setInt(4, replyto);
      } else {
        pst.setNull(4, Types.INTEGER);
      }

      //pst.setString(6, request.getRemoteAddr());
      pst.executeUpdate();
      pst.close();

      // insert message text
      PreparedStatement pstMsgbase = db.prepareStatement("INSERT INTO msgbase (id, message) values (?,?)");
      pstMsgbase.setLong(1, msgid);
      pstMsgbase.setString(2, msg);
      pstMsgbase.executeUpdate();
      pstMsgbase.close();

      String logmessage = "������� ����������� " + msgid + " ip:" + request.getRemoteAddr();
      if (request.getHeader("X-Forwarded-For") != null) {
        logmessage = logmessage + " XFF:" + request.getHeader(("X-Forwarded-For"));
      }

      logger.info(logmessage);

      Random random = new Random();

      response.setHeader("Location", tmpl.getRedirectUrl() + returnUrl + "&nocache=" + random.nextInt());
      response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);

      db.commit();
      rs.close();
      st.close();

%>
<title>���������� ��������� ������ �������</title>
<%= tmpl.DocumentHeader() %>
<p>��������� �������� �������

<p><a href="<%= tmpl.getRedirectUrl()+returnUrl %>">�������</a>

<p><b>����������, �� ��������� ������ "ReLoad" ������ �������� �� ���� ��������� � �� ������������� �� ��� �� ��������� ������ Back</b>
<%
} catch (UserErrorException e) {
	error=e;
	showform=true;
	if (db!=null) {
		db.rollback();
		db.setAutoCommit(true);
	}
} catch (UserNotFoundException e) {
	error=e;
	showform=true;
	if (db!=null) {
		db.rollback();
		db.setAutoCommit(true);
	}
} catch (UtilBadURLException e) {
	error=e;
	showform=true;
	if (db!=null) {
		db.rollback();
		db.setAutoCommit(true);
	}
}
%>

<% }

if (showform) { // show form
  if (db==null) {
    db = tmpl.getConnection("add_comment");
  }

  Message topic = new Message(db, topicId);

  if (topic.isExpired()) {
    throw new AccessViolationException("������ ��������� � ���������� ����");
  }

  if (topic.isDeleted()) {
    throw new AccessViolationException("������ ��������� � ��������� ����");
  }

  int postscore = topic.getPostScore();
%>

<title>�������� ���������</title>
<%= tmpl.DocumentHeader() %>
<% if (error==null) { %>
<h1>�������� �����������</h1>
<% } else { out.println("<h1>������: "+error.getMessage()+"</h1>"); } %>

<% if (tmpl.getProf().getBoolean("showinfo") && !tmpl.isSessionAuthorized(session)) { %>
<font size=2>����� ������ ��������� ���������, ����������� login `anonymous',
��� ������. ���� �� ����������� ������� ����������� � ������,
�������� ������� �� ������� ��������,
<a href="register.jsp">�����������������</a></font>.
<p>

<% } %>
<font size=2><strong>��������!</strong> ����� ���������� ����������� ������������ �
<a href="rules.jsp">���������</a> �����.</font><p>

<%
  out.print(Message.getPostScoreInfo(postscore));
%>

<form method=POST action="add_comment.jsp">
  <input type="hidden" name="session" value="<%= HTMLFormatter.htmlSpecialChars(session.getId()) %>">
<% if (!tmpl.isSessionAuthorized(session)) { %>
���:
<input type=text name=nick value="<%= "anonymous" %>" size=40><br>
������:
<input type=password name=password size=40><br>
<% } %>
<input type=hidden name=topic value="<%= topicId %>">

<% if (request.getParameter("return")!=null) { %>
<input type=hidden name=return value="<%= HTMLFormatter.htmlSpecialChars(request.getParameter("return")) %>">
<% } %>

<% if (request.getParameter("replyto")!=null) {
        int replyto=Integer.parseInt(request.getParameter("replyto"));
%>
<input type=hidden name=replyto value="<%= replyto %>">
<%
  Comment comment = new Comment(db, replyto);
  if (comment.isDeleted()) throw new MessageNotFoundException(replyto);
  String title = comment.getTitle();
  if (!title.startsWith("Re:")) title = "Re: " + title;

  out.print("<div class=messages>");
  out.print(comment.printMessage(tmpl, db, false, "", tmpl.isModeratorSession(), Template.getNick(session), false));
  out.print("</div>");

  if (request.getParameter("title") != null) title = request.getParameter("title");
%>
��������:
<input type=text name=title size=40 value="<%= title %>"><br>
<% } else if (request.getParameter("title")==null) {%>
��������:
<input type=text name=title size=40><br>
<% } else { %>
��������:
<input type=text name=title size=40 value="<%= HTMLFormatter.htmlSpecialChars(request.getParameter("title")) %>"><br>
<% } %>

���������:<br>
<font size=2>(� ������ <i>Tex paragraphs</i> ������������ �������� �����.<br> ������ ������ (��� ���� Enter) �������� ����� �����.<br> ���� '&gt;' � ������ ������ �������� ����� �������� �����������)</font><br>
<textarea name="msg" cols="70" rows="20" onkeypress="return ctrl_enter(event, this.form);"><%= request.getParameter("msg")==null?"":HTMLFormatter.htmlSpecialChars(request.getParameter("msg")) %></textarea><br>

<select name=mode>
<option value=quot>TeX paragraphs w/quoting
<option value=tex>TeX paragraphs w/o quoting
<option value=ntobr>User line break
<option value=html>Ignore line breaks
<option value=pre>Preformatted text
</select>

<select name=autourl>
<option value=1>Auto URL
<option value=0>No Auto URL
</select>

<input type=hidden value=0 name=texttype>

<br>

<%
  out.print(Message.getPostScoreInfo(postscore));
%>

<br>
<%
  if (!Template.isSessionAuthorized(session)) {
    out.print("<p><img src=\"/jcaptcha.jsp\"><input type='text' name='j_captcha_response' value=''>");
  }
%>
<input type=submit value="Post/���������">


</form>
<%
   }
} finally {
  if (db!=null) db.close();
}
%>
<%=	tmpl.DocumentFooter() %>
