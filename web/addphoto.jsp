<%@ page contentType="text/html; charset=koi8-r"%>
<%@ page import="java.io.File, java.io.IOException, java.io.FileNotFoundException, java.net.URLEncoder, java.sql.Connection" errorPage="/error.jsp"%>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.util.Random" %>
<%@ page import="java.util.logging.Logger" %>
<%@ page import="ru.org.linux.site.*" %>
<%@ page import="ru.org.linux.util.BadImageException" %>
<%@ page import="ru.org.linux.util.ImageInfo" %>
<%@ page import="org.apache.commons.fileupload.FileItem, org.apache.commons.fileupload.FileUploadException, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<% Template tmpl = new Template(request, config, response);
  Logger logger = Logger.getLogger("ru.org.linux");
%>
<%= tmpl.head() %>
<title>����������/��������� ����������</title>
<%= tmpl.DocumentHeader() %>

<div class=messages>
<div class=nav>

<div class="color1">
  <table width="100%" cellspacing=1 cellpadding=1 border=0><tr class=body>
    <td align=left valign=middle>
      ����������/��������� ����������
    </td>

    <td align=right valign=middle>
      [<a style="text-decoration: none" href="register.jsp?mode=change">��������� �����������</a>]
      [<a style="text-decoration: none" href="rules.jsp">������� ������</a>]
     </td>
    </tr>
 </table>
</div>

</div>
</div>

<h1>����������/��������� ����������</h1>

<%
  boolean showForm = request.getMethod().equals("GET");
  Exception error = null;

  if (!Template.isSessionAuthorized(session)) {
    throw new AccessViolationException("Not autorized");
  }

  if (request.getMethod().equals("POST")) {
    Connection db = null;

    try {
      String filename = "";
	  if (!ServletFileUpload.isMultipartContent(request) || request.getParameter("file") != null) {
		filename = request.getParameter("file");
	  } else {
		// Load file from multipart request
		java.io.File rep = new java.io.File(tmpl.getObjectConfig().getPathPrefix()+"/linux-storage/tmp/");
		// Create a factory for disk-based file items
		DiskFileItemFactory factory = new DiskFileItemFactory();
		// Set factory constraints
		factory.setSizeThreshold(500000);
		factory.setRepository(rep); 
		// Create a new file upload handler
		ServletFileUpload upload = new ServletFileUpload(factory);
		// Set overall request size constraint
		upload.setSizeMax(600000);
		// Parse the request
		java.util.List items = upload.parseRequest(request);
		// Process the uploaded items
		java.util.Iterator iter = items.iterator();
		while (iter.hasNext()) {
		  FileItem item = (FileItem) iter.next();
		  if (!item.isFormField()) {
			String fieldName = item.getFieldName();
			String fileName = item.getName();
			String contentType = item.getContentType();
			boolean isInMemory = item.isInMemory();
			long sizeInBytes = item.getSize();
			if (fieldName.compareToIgnoreCase("file")==0 && fileName!=null && !"".equals(fileName)) {
			  filename = tmpl.getObjectConfig().getPathPrefix()+"/linux-storage/tmp/"+fileName;
			  java.io.File uploadedFile = new java.io.File(filename);
			  if (uploadedFile!=null && (uploadedFile.canWrite() || uploadedFile.createNewFile())) {
				item.write(uploadedFile);
			  } else {
				throw new BadInputException("������ ����������");
			  }
			} else {
			  throw new BadInputException("������ ��������");
			}
		  } else {
			// Form field
		  }
		} // while
	  }
      Userpic.checkUserpic(filename);

      db = tmpl.getConnection("addphoto");
      User user = User.getUser(db, (String) session.getAttribute("nick"));
      user.checkAnonymous();

      File file = new File(filename);
      String extension = ImageInfo.detectImageType(filename);

      Random random = new Random();

      String photoname;
      File photofile;

      do {
        photoname = Integer.toString(user.getId()) + ":" + random.nextInt() + "." + extension;
        photofile = new File(tmpl.getObjectConfig().getHTMLPathPrefix() + "/photos", photoname);
      } while (photofile.exists());

      file.renameTo(photofile);

      PreparedStatement pst = db.prepareStatement("UPDATE users SET photo=? WHERE id=?");
      pst.setString(1, photoname);
      pst.setInt(2, user.getId());
      pst.executeUpdate();

      logger.info("����������� ���������� ������������� " + user.getNick());

      response.sendRedirect(tmpl.getMainUrl() + "whois.jsp?nick=" + URLEncoder.encode(user.getNick()) + "&nocache=" + random.nextInt());
    } catch (IOException ex) {
      showForm = true;
      error = ex;
    } catch (BadImageException ex) {
      showForm = true;
      error = ex;
    } catch (UserErrorException ex) {
      showForm = true;
      error = ex;
    } finally {
      if (db != null) {
        db.close();
      }
    }
  }

  if (showForm) {
%>
<p>
��������� ���� ���������� � �����. ����������� ������ ��������������� <a href="rules.jsp">��������</a> �����.
</p>
<p>
  ����������� ���������� � �����������:
  <ul>
    <li>������ x ������: �� 50x50 �� 150x150 ��������</li>
    <li>���: jpeg, gif, png</li>
    <li>������ �� ����� 20 Kb</li>
  </ul>
</p>

<form action="addphoto.jsp" method="POST" enctype="multipart/form-data">
<% if (error != null) {
  out.print("<strong>������! " + error.getMessage() + "</strong><br>");
  //error.printStackTrace(new PrintWriter(out));
}
%>
  <input type="file" name="file"><br>
  <input type="submit" value="���������">
</form>
<%
  }
%>

<%=	tmpl.DocumentFooter() %>
