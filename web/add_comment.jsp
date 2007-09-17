<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="java.sql.Connection,java.sql.Statement,java.util.Random,java.util.logging.Logger,javax.servlet.http.HttpServletResponse,ru.org.linux.site.*" errorPage="/error.jsp"%>
<%@ page import="ru.org.linux.util.HTMLFormatter"%>
<%@ page import="ru.org.linux.util.UtilBadHTMLException" %>
<%@ page import="ru.org.linux.util.UtilBadURLException" %>
<% Template tmpl = new Template(request, config, response);%>
<%
  Logger logger = Logger.getLogger("ru.org.linux");

  int topicId = tmpl.getParameters().getInt("topic");
  boolean showform = request.getParameter("msg") == null;
  boolean preview = request.getParameter("preview") != null;

  if (!"POST".equals(request.getMethod()) || preview)
    showform = true;
%>
<%= tmpl.head() %>

<%
  Connection db = null;
  try {
%>

<%
  Exception error = null;
  String mode = "";
  boolean autourl = true;
  Comment comment = null;
  if (!showform || preview) { // add2
    mode = tmpl.getParameters().getString("mode");
    autourl = tmpl.getParameters().getBoolean("autourl");
    String msg = request.getParameter("msg");

    int replyto = 0;

    if (request.getParameter("replyto") != null) {
      replyto = tmpl.getParameters().getInt("replyto");
    }

    if (!preview && !session.getId().equals(request.getParameter("session"))) {
      logger.info("Flood protection (session variable differs: " + session.getId() + ") " + request.getRemoteAddr());
      throw new BadInputException("���� ����������");
    }

    String title = request.getParameter("title");

    if (title == null) {
      title = "";
    }

    title = HTMLFormatter.htmlSpecialChars(title);

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

    comment = new Comment(replyto, title, msg, topicId, 0);

    try {
      if ("".equals(title)) {
        throw new BadInputException("��������� ��������� �� ����� ���� ������");
      }

      if ("".equals(msg)) {
        throw new BadInputException("����������� �� ����� ���� ������");
      }

      if (!preview && !Template.isSessionAuthorized(session)) {
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
        user = User.getUser(db, request.getParameter("nick"));
        user.checkPassword(request.getParameter("password"));
      } else {
        user = User.getUser(db, (String) session.getAttribute("nick"));
        user.checkBlocked();
      }

      comment.setAuthor(user.getId());

      if (user.isAnonymous()) {
        if (msg.length() > 4096) {
          throw new BadInputException("������� ������� ���������");
        }
      } else {
        if (msg.length() > 8192) {
          throw new BadInputException("������� ������� ���������");
        }
      }

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

      topic.checkPostAllowed(user, tmpl.isModeratorSession());

      if (!preview) {
        DupeProtector.getInstance().checkDuplication(request.getRemoteAddr());

        int msgid = comment.saveNewMessage(db, request.getRemoteAddr());

        String logmessage = "������� ����������� " + msgid + " ip:" + request.getRemoteAddr();
        if (request.getHeader("X-Forwarded-For") != null) {
          logmessage = logmessage + " XFF:" + request.getHeader(("X-Forwarded-For"));
        }

        logger.info(logmessage);

        topic = new Message(db, topicId); // update lastmod

        CommentList commentList = CommentList.getCommentList(db, topic, false);
        Comment newComment = commentList.getNode(msgid).getComment();
        int pageNum = commentList.getCommentPage(newComment, tmpl);

        Random random = new Random();

        String returnUrl;

        if (pageNum > 0) {
          returnUrl = "view-message.jsp?msgid=" + topicId + "&page=" + pageNum + "&nocache=" + random.nextInt() + "#" + msgid;
        } else {
          returnUrl = "view-message.jsp?msgid=" + topicId + "&nocache=" + random.nextInt() + "#" + msgid;
        }

        response.setHeader("Location", tmpl.getMainUrl() + returnUrl);
        response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);

        db.commit();
        st.close();

%>
<title>���������� ��������� ������ �������</title>
<%= tmpl.DocumentHeader() %>
<p>��������� �������� �������

<p><a href="<%= returnUrl %>">�������</a>

<p><b>����������, �� ��������� ������ "ReLoad" ������ �������� �� ���� ��������� � �� ������������� �� ��� �� ��������� ������ Back</b>
<%		
			} 
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

<% if (tmpl.getProf().getBoolean("showinfo") && !Template.isSessionAuthorized(session)) { %>
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
<% if (!Template.isSessionAuthorized(session)) { %>
���:
<input type=text name=nick value="<%= "anonymous" %>" size=40><br>
������:
<input type=password name=password size=40><br>
<% } %>
<input type=hidden name=topic value="<%= topicId %>">

<% if (request.getParameter("return")!=null) { %>
<input type=hidden name=return value="<%= HTMLFormatter.htmlSpecialChars(request.getParameter("return")) %>">
<% } %>
<%
  String title = "";

  if (request.getParameter("replyto")!=null) {
    int replyto=Integer.parseInt(request.getParameter("replyto"));
%>
<input type=hidden name=replyto value="<%= replyto %>">
<%
    Comment onComment = new Comment(db, replyto);

    if (onComment.isDeleted()) {
      throw new MessageNotFoundException(replyto);
    }

    title = onComment.getTitle();
    if (!title.startsWith("Re:")) {
      title = "Re: " + title;
    }

    out.print("<div class=messages>");
    CommentView view = new CommentView();
    out.print(view.printMessage(onComment, tmpl, db, null, false, tmpl.isModeratorSession(), Template.getNick(session), false));
    out.print("</div>");
  }

  if (request.getParameter("title") != null) {
    title = request.getParameter("title");
  }

  if (preview && comment!=null) {
    out.print("<p><b>���� ���������</b></p>");
    out.print("<div class=messages>");
    CommentView view = new CommentView();
    out.print(view.printMessage(comment, tmpl, db, null, false, tmpl.isModeratorSession(), Template.getNick(session), false));
    out.print("</div>");
  }

  if (request.getParameter("replyto") != null) {
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
<option value=quot <%= (preview && mode.equals("quot"))?"selected":""%> >TeX paragraphs w/quoting
<option value=tex <%= (preview && mode.equals("tex"))?"selected":""%> >TeX paragraphs w/o quoting
<option value=ntobr <%= (preview && mode.equals("ntobr"))?"selected":""%> >User line break
<option value=html <%= (preview && mode.equals("html"))?"selected":""%> >Ignore line breaks
<option value=pre <%= (preview && mode.equals("pre"))?"selected":""%> >Preformatted text
</select>

<select name=autourl>
<option value=1 <%= (preview && autourl)?"selected":""%> >Auto URL
<option value=0 <%= (preview && !autourl)?"selected":""%> >No Auto URL
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
<input type=submit name=preview value="Preview/������������">

</form>
<%
   }
} finally {
  if (db!=null) db.close();
}
%>
<%=	tmpl.DocumentFooter() %>
