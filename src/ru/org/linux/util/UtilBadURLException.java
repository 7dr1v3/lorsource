package ru.org.linux.util;

public class UtilBadURLException extends UtilException {
	UtilBadURLException() {
		super("������������ URL");
	}

	UtilBadURLException(String URL) {
		super("������������ URL: "+URL);
	}
}
