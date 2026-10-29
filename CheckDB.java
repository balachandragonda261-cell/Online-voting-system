import java.sql.*;

public class CheckDB {
    public static void main(String[] args) throws Exception {
        String url = "jdbc:h2:./voting_db;MODE=MySQL;DATABASE_TO_LOWER=TRUE;AUTO_SERVER=TRUE";
        Connection conn = DriverManager.getConnection(url, "sa", "");
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM users");
        while (rs.next()) {
            System.out.println("ID: " + rs.getInt("id") + ", Email: " + rs.getString("email") + ", Hash: " + rs.getString("password_hash"));
        }
        rs.close();
        stmt.close();
        conn.close();
    }
}
