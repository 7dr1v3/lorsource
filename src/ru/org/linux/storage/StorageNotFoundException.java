package ru.org.linux.storage;

public class StorageNotFoundException extends StorageException {
  public StorageNotFoundException(String domain, int msgid) {
    super("�� ������ ������ " + domain + ':' + msgid);
  }

  public StorageNotFoundException(String domain, String msgid) {
    super("�� ������ ������ " + domain + ':' + msgid);
  }

  public StorageNotFoundException(String domain, String msgid, Exception e) {
    super("�� ������ ������ " + domain + ':' + msgid, e);
  }
}