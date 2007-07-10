package ru.org.linux.site.boxes;

import java.io.IOException;
import java.util.Properties;

import ru.org.linux.boxlet.Boxlet;
import ru.org.linux.util.ProfileHashtable;

public final class profile extends Boxlet
{
	public String getContentImpl(ProfileHashtable profile) throws IOException {
		StringBuffer out=new StringBuffer();

		out.append("<h2>����� �������</h2>");
		if (profile.getString("ProfileName")==null)
			out.append("������������ ������� ��-���������<p>");
		else
			out.append("������������ �������: <em>"+profile.getString("ProfileName")+"</em><p>");
		out.append("<br><a href=\"edit-profile.jsp\">���������...</a>");

		out.append("<p><strong>�������������:</strong><br>");
		out.append("*<a href=\"edit-profile.jsp?mode=setup&amp;profile=\">�� ���������</a><br>");
		out.append("*<a href=\"edit-profile.jsp?mode=setup&amp;profile=_white\">���� white</a><br>");
		out.append("*<a href=\"edit-profile.jsp?mode=setup&amp;profile=_white2\">���� white2</a><br>");

		return out.toString();
	}

	public String getInfo() { return "����� �������"; }

	public String getVariantID(ProfileHashtable prof, Properties request) {
		if (prof.getString("ProfileName")==null)
			return "";
		else
			return "ProfileName="+prof.getString("ProfileName");
	}
}
