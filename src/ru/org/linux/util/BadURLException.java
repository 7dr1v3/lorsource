package ru.org.linux.util;

public class BadURLException extends UtilException {
  public BadURLException() {
    super("������������ URL");
  }

  public BadURLException(String URL) {
    super("������������ URL: " + URL);
  }
}
