package ru.org.linux.site;

public class ScriptErrorException extends Exception {
  public ScriptErrorException() {
    super("����������� ������ �������");
  }

  public ScriptErrorException(String info) {
    super(info);
  }
}