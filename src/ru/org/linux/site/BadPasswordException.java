package ru.org.linux.site;

public class BadPasswordException extends UserErrorException
{
	public BadPasswordException(String name)
	{
		super("������ ��� ������������ \""+name+"\" ����� �������");
	}
}