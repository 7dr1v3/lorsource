package ru.org.linux.site;

public class BadSectionException extends ScriptErrorException {
  public BadSectionException(int id) {
    super("����������� ����� ����� ������: "+id);
  }
}