package ru.org.linux.storage;

public class StorageBadDomainException extends StorageException {
  public StorageBadDomainException(String domain) {
    super("������������ ��� ������ " + domain);
  }
}