package ru.org.linux.storage;

public class StorageExistsException extends StorageException
{
	public StorageExistsException(String domain, int msgid)
	{
		super("������ "+domain+ ':' +msgid+" ��� ����������");
	}

	public StorageExistsException(String domain, String msgid)
	{
		super("������ "+domain+ ':' +msgid+" ��� ����������");
	}
}