package utils;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;


public class DataSourceUtil {
    private static volatile DataSource ds;

    private DataSourceUtil() {}

    public static DataSource getDataSource() {
        if (ds == null) {
            synchronized (DataSourceUtil.class) {
                if (ds == null) {
                    ds = lookup("java:comp/env/jdbc/canteenstoreDS");
                }
            }
        }
        return ds;
    }

    private static DataSource lookup(String jndiName) {
        try {
            Context ctx = new InitialContext();
            Context envContext  = (Context)ctx.lookup("java:comp/env");
            ds = (DataSource)envContext.lookup("jdbc/canteenstoreDS");
            return ds;
        } catch (Exception e) {
            throw new RuntimeException("Không lookup được JNDI DataSource: " + jndiName, e);
        }
    }

	public static void close() {
		// TODO Auto-generated method stub
		
	}
}
