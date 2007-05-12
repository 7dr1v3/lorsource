package ru.org.linux.util;

public final class DateUtil {
  private DateUtil() {
  }

  /**
   * Returns string name of specified month number
   *
   * @param        month        1..12
   */
  public static String getMonth(int month) throws BadDateException {
    switch (month - 1) {
      case 0:
        return "������";
      case 1:
        return "�������";
      case 2:
        return "����";
      case 3:
        return "������";
      case 4:
        return "���";
      case 5:
        return "����";
      case 6:
        return "����";
      case 7:
        return "������";
      case 8:
        return "��������";
      case 9:
        return "�������";
      case 10:
        return "������";
      case 11:
        return "�������";
      default:
        throw new BadDateException("������ ����� " + month);
    }
  }

}
