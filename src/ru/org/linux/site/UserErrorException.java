package ru.org.linux.site;

public class UserErrorException extends Exception
{
	public UserErrorException()
	{
		super("����������� ���������������� ������");
	}

	public UserErrorException(String info)
	{
		super(info);
	}

}