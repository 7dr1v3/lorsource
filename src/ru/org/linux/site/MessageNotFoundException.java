package ru.org.linux.site;

public class MessageNotFoundException extends ScriptErrorException {
  public MessageNotFoundException(int id) {
    super("��������� #" + id + " �� ����������");
  }
}