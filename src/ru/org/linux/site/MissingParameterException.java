package ru.org.linux.site;

public class MissingParameterException extends ScriptErrorException
{
	public MissingParameterException(String param)
	{
		super("�������� ��������� '"+param+ '\'');
	}
}