package ru.org.linux.site;

public class BadParameterException extends ScriptErrorException
{
	public BadParameterException(String param, String info)
	{
		super("������������ ������ ��������� ``"+param+"'': "+info);
	}

	public BadParameterException(String param)
	{
		super("������������ ������ ��������� ``"+param+"''");
	}

}