<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page
    import="java.sql.Connection,java.sql.PreparedStatement,ru.org.linux.site.AccessViolationException,ru.org.linux.site.Message,ru.org.linux.site.Template,ru.org.linux.util.HTMLFormatter"
    errorPage="/error.jsp" buffer="200kb" %>
<%
  Template tmpl = new Template(request, config, response);

  if (!tmpl.isModeratorSession()) {
    throw new IllegalAccessException("Not authorized");
  }

  int msgid = tmpl.getParameters().getInt("msgid");

  out.print(tmpl.DocumentHeader());

  Connection db = null;
  try {
      db = tmpl.getConnection("edit");
      db.setAutoCommit(false);
      Message message = new Message(db, msgid);

      String sMsgTitle = message.getTitle();
      String sURL = message.getUrl();
      String sURLtitle = message.getLinktext();
      boolean debugme = false;

      if (message.isExpired() && message.isDeleted()) {
        throw new AccessViolationException("������ ������� ����������/��������� ���������");
      }
      if (message.isDeleted()) {
        throw new AccessViolationException("��������� �������");
      }

//cText = storage.readMessage(msgDomain, MsgId);

      String cText = message.getMessageText();

      if (debugme) {
        out.print("<!-- old message = " + cText + "\n msglen: " + cText.length() + " -->\n");
      }
      String cnText = request.getParameter("newmsg");
      if (request.getMethod().equals("POST") && (cnText != null)) {
        if (debugme) {
          out.print("<!-- new message = " + cnText + "\n msglen: " + cnText.length() + " -->\n");
          out.print("<!-- method is POST -->\n");
        }
        // do changes to message
        boolean modified = false;
        // update db
        String snMsgTitle = request.getParameter("title");
        String snURLtitle = request.getParameter("url_text");
        String snURL = request.getParameter("url");

        db = tmpl.getConnection("edit");

        String sSql = "UPDATE topics SET title=?, linktext=?, url=? WHERE id=?";
        PreparedStatement pst = db.prepareStatement(sSql);

        pst.setString(1, snMsgTitle);

        if (!snMsgTitle.equals(sMsgTitle)) {
          modified = true;
        }

        if (!cText.equals(cnText)) {
          modified = true;
          message.updateMessageText(db, cnText);
        }

        pst.setString(2, snURLtitle);

        if (snURLtitle!=null && !snURLtitle.equals(sURLtitle)) {
          modified = true;
        }

        pst.setString(3, snURL);

        if (snURL!=null && !snURL.equals(sURL)) {
          modified = true;
        }

        pst.setInt(4, msgid);

        if (modified) {
          pst.executeUpdate();

          out.print("<a href='view-message.jsp?msgid=" + msgid + "'>��������� ����������</a>.<br>\n");
          // out.print("�������� � ������� 5 ������.\n");
          tmpl.getLogger().notice("edit.jsp", "��������� " + msgid + " ���������� " + session.getValue("nick"));
        } else {
          out.print("nothing changed.\n");
        }
      } else {
        out.print("<!-- method is GET -->\n");
        // show edit form
%>
<form name="edit" method="post">
  ��������� ������� :
  <% if ((sMsgTitle != null) && (sMsgTitle.length() != 0)) {
    out.print("<input type=\"text\" name=\"title\" size=\"70\" value=\"" + HTMLFormatter.htmlSpecialChars(sMsgTitle) + "\">\n");
  } else {
    out.print("<input type=\"text\" name=\"title\" size=\"70\" value='' disabled>\n");
  }
  %>
  <br>
  <textarea name="newmsg" cols="70" rows="20"><%= cText %></textarea>
  <br><br>
  ����� ������ :
  <% if ((sURLtitle != null) && (sURLtitle.length() != 0)) {
    out.print("<input type=\"text\" name=\"url_text\" size=\"78\" value=\"" + sURLtitle + "\">\n");
  } else {
    out.print("<input type=\"text\" name=\"url_text\" size=\"78\" value='' disabled>\n");
  }
  %>
  <br>
  ������ :
  <% if ((sURL != null) && (sURL.length() != 0)) {
    out.print("<input type=\"text\" name=\"url\" size=\"84\" value=\"" + sURL + "\">\n");
  } else {
    out.print("<input type=\"text\" name=\"url\" size=\"84\" value='' disabled>\n");
  }
  %>
  <br><br>
  <input type="submit" value="���������������">
  &nbsp;
  <input type="reset" value="��������">
</form>
<%
      }

    db.commit();
    // out.print("<-- or msgid is null -->\n");
  } finally {
    if (db != null) {
      db.close();
    }
  }

  out.print(tmpl.DocumentFooter());
%>
