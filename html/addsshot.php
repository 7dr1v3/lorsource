<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"
                    "http://www.w3.org/TR/REC-html40/loose.dtd">
<HTML>
<HEAD>
	<TITLE>���������� ���������</TITLE>
<?php include("head.html"); ?>
<?php
/*	echo "<p><div align=center><b>� ����� � ������������� ������� ���������� ������� ����� ����������� ������������� �� ������� 2003</b></div>";
	include("footer.html"); 
	exit();	 */
?>


<h1>���������� ���������</h1>
<?php 
if ($HTTP_POST_VARS[profile])
	$profile = $HTTP_POST_VARS[profile];

#   $conn = connect_db();
######### login ############

if ($HTTP_POST_VARS[add])
{
if (!$_FILES[userfile])
   {
     echo "<b>������</b>: �� ������ ������� ����.";
     $errors=1;
   }

}
######### end login ########

if (!$HTTP_POST_VARS[add])
{
echo"<p><b>�����������:</b>";
echo"<br>������ x ������: �� 400x400 �� 2048x2048 ��������";
echo"<br>���: jpeg, gif, png";
echo"<br>������ �� ����� 300 Kb";
echo"<FORM ENCTYPE=\"multipart/form-data\" ACTION=\"addsshot.php\" METHOD=POST>";
echo"<INPUT TYPE=hidden name=add value=1>";
echo"<INPUT TYPE=hidden name=profile value=$profile>";
echo"<INPUT TYPE=hidden name=MAX_FILE_SIZE value=350000>";
echo"<br>��������: <INPUT NAME=userfile TYPE=file>";
echo"<br><INPUT TYPE=submit VALUE=\"���������/Send\">";
echo"</FORM>";
echo "������� �� ������� ������ �������� ���������.";
}

if ( (!$errors) & ($HTTP_POST_VARS[add]) )
   {
if ($debug==1) {
echo"<hr>";
echo"<br>File: ".$_FILES[userfile][tmp_name];
echo"<br>Name: ".$_FILES[userfile][name];   
echo"<br>Size: ".$_FILES[userfile][size];   
echo"<br>Type: ".$_FILES[userfile][type];   
echo"<hr>";
}

$userfile_size = $_FILES[userfile][size];
$userfile_type = $_FILES[userfile][type];
$userfile = $_FILES[userfile][tmp_name];

if ($userfile_size>350000) 
              {
                echo"<br><b>������:</b> ������� ������� ������ �����. �� �� ������ ��������� 300 Kb";
                $errors=1;
		echo"<!-- $userfile_size -->";
              }
if ( ($userfile_type!="image/jpeg") && ($userfile_type!="image/gif") && ($userfile_type!="image/pjpeg") && ($userfile_type!="image/png") && ($userfile_type!="image/x-png")  ) 
              {
                echo"<br><b>������:</b> �������� ��� �����: ".$userfile_type;
                $errors=1;
		echo"<!-- $userfile_type -->";
              }

     if ($userfile_type=="image/jpeg") $suffix=".jpg";
     if ($userfile_type=="image/pjpeg") $suffix=".jpg";
     if ($userfile_type=="image/gif") $suffix=".gif";
     if ($userfile_type=="image/png") $suffix=".png";
     if ($userfile_type=="image/x-png") $suffix=".png";

     $filename=tempnam("gallery","big") . $suffix;

     move_uploaded_file($userfile, $filename);

  if (!$errors)
   {

      $size = GetImageSize($filename);
      echo"<p>������ ����������: $size[0]x$size[1]";

        if ( ($size[0]<400) || ($size[0]>2048) || ($size[1]<400) || ($size[1]>2048) )
              {
                echo"<br><b>������:</b> ������������ ������� ����������.";
                $errors=1;
		delete($filename);
              }
   }

if (!$errors)
 {
    echo"<h3>���������� ������ ����.</h3>";


         echo"<h3>��������� ������<br></h3>";

	 $small=tempnam("gallery", "small") . ".png";

	 system("/usr/bin/convert -scale 150 $filename $small");
	 if (!file_exists($small)) echo "cant build icon - broken image?";
		else {
			echo "<img src=\"$small\" alt=\"preview\">";

			if ($profile)
				echo "<p>���� �� ������� ������ - ������� " . "<a href=\"http://www.linux.org.ru/profile/$profile/add.jsp?group=4962&url=". urlencode($filename) . "&icon=" . urlencode($small) . "\">����������</a>.";
			else
				echo "<p>���� �� ������� ������ - ������� " . "<a href=\"http://www.linux.org.ru/add.jsp?group=4962&url=". urlencode($filename) . "&icon=" . urlencode($small) . "\">����������</a>.";

		}

  }	
	
 }


?>
</center>
<?php include("footer.html"); ?>
</BODY>
</HTML>
