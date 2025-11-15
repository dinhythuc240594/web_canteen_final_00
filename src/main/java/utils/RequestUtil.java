package utils;

import jakarta.servlet.http.HttpServletRequest;

public class RequestUtil {

	public static int getInt(HttpServletRequest request, String name, int defaultValue) {
		try {
			int value = Integer.parseInt(request.getParameter(name));
//			System.out.println(name + ": " + int.toString(value));
			return value > 0 ? value:defaultValue;
		} catch (Exception e) {
//			System.out.println("default " + name + ": " + int.toString(defaultValue));
			return defaultValue;
		}
	}
	
	public static String getString(HttpServletRequest request, String name, String defaultValue) {
		try {
			String value = (String)(request.getParameter(name));
//			System.out.println(name + ": " + value);
			return value != null ? value:defaultValue;
		} catch (Exception e) {
//			System.out.println("default " + name + ": " + defaultValue);
			return defaultValue;
		}
	}
	
}
