import org.mindrot.jbcrypt.BCrypt;

public class CheckHash {
    public static void main(String[] args) {
        String hash = "$2a$10$wN2ZqA4Zf5wZtVvR9b4nOu8u7l0hI6bX0n9x3f0vN.mD/9lY8l2P6";
        String password = "admin123";
        boolean match = BCrypt.checkpw(password, hash);
        System.out.println("Match? " + match);
        System.out.println("New hash: " + BCrypt.hashpw(password, BCrypt.gensalt()));
    }
}
