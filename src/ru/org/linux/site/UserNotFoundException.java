package ru.org.linux.site;

public class UserNotFoundException extends ScriptErrorException {
  public UserNotFoundException(String name) {
    super("������������ \"" + name + "\" �� ����������");
  }

  public UserNotFoundException(int id) {
    super("������������ id=" + id + " �� ����������");
  }

}