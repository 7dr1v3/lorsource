package ru.org.linux.util;

public class UtilKeyNotFoundException extends UtilException {
  UtilKeyNotFoundException(String key) {
    super("���� `" + key + "' �� ������");
  }
}
