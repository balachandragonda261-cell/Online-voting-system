import java.sql.*;

public class DumpDB {
    public static void main(String[] args) throws Exception {
        String url = "jdbc:h2:./voting_db;MODE=MySQL;DATABASE_TO_LOWER=TRUE;AUTO_SERVER=TRUE";
        try (Connection conn = DriverManager.getConnection(url, "sa", "")) {
            printTable(conn, "users");
            printTable(conn, "elections");
            printTable(conn, "candidates");
            printTable(conn, "votes");
            printTable(conn, "audit_logs");
        }
    }

    private static void printTable(Connection conn, String tableName) throws SQLException {
        System.out.println("--- Table: " + tableName + " ---");
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM " + tableName)) {
            
            ResultSetMetaData rsmd = rs.getMetaData();
            int colCount = rsmd.getColumnCount();
            
            for (int i = 1; i <= colCount; i++) {
                System.out.print(rsmd.getColumnName(i) + "\t|\t");
            }
            System.out.println("\n------------------------------------------------");
            
            while (rs.next()) {
                for (int i = 1; i <= colCount; i++) {
                    System.out.print(rs.getString(i) + "\t|\t");
                }
                System.out.println();
            }
        }
        System.out.println();
    }
}
