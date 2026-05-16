<?php
/**
 * Create an initial admin user.
 * Usage (CLI):
 *   php create_admin.php --username=admin --password=admin123 --email=admin@example.com
 * If run via web, only allowed from localhost and requires `confirm=1` query param.
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/database.php';

$is_cli = PHP_SAPI === 'cli';

// Parse args
$opts = [];
if ($is_cli) {
    $opts = getopt('', ['username:', 'password:', 'email::']);
} else {
    // web
    $opts['username'] = $_REQUEST['username'] ?? null;
    $opts['password'] = $_REQUEST['password'] ?? null;
    $opts['email'] = $_REQUEST['email'] ?? null;
    $confirm = $_REQUEST['confirm'] ?? '0';
    $remote = $_SERVER['REMOTE_ADDR'] ?? '';
    if (!in_array($remote, ['127.0.0.1', '::1', '::ffff:127.0.0.1'], true) || $confirm !== '1') {
        http_response_code(403);
        echo "Forbidden: web access allowed only from localhost with confirm=1\n";
        exit;
    }
}

$username = $opts['username'] ?? null;
$password = $opts['password'] ?? null;
$email = $opts['email'] ?? null;

if (empty($username) || empty($password)) {
    if ($is_cli) {
        echo "Usage: php create_admin.php --username=admin --password=admin123 [--email=admin@example.com]\n";
    } else {
        echo "Missing username or password";
    }
    exit(1);
}

try {
    $db = Database::getInstance()->getConnection();

    // Ensure admin_users table exists (idempotent)
    $db->exec("CREATE TABLE IF NOT EXISTS admin_users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(150) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(255) DEFAULT NULL,
        email VARCHAR(255) DEFAULT NULL,
        role VARCHAR(50) DEFAULT 'admin',
        is_active TINYINT(1) DEFAULT 1,
        last_login DATETIME DEFAULT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;"
    );

    // Check if user exists
    $stmt = $db->prepare('SELECT id FROM admin_users WHERE username = :username LIMIT 1');
    $stmt->execute([':username' => $username]);
    $exists = $stmt->fetch();
    if ($exists) {
        echo "User '{$username}' already exists (id={$exists['id']}).\n";
        exit(0);
    }

    $hash = password_hash($password, PASSWORD_DEFAULT);
    $ins = $db->prepare('INSERT INTO admin_users (username, password_hash, full_name, email, role, is_active) VALUES (:username, :hash, :full, :email, :role, 1)');
    $ins->execute([
        ':username' => $username,
        ':hash' => $hash,
        ':full' => ucfirst($username),
        ':email' => $email,
        ':role' => 'admin'
    ]);

    $id = $db->lastInsertId();
    echo "Created admin user '{$username}' with id={$id}.\n";
    exit(0);
} catch (Throwable $e) {
    fwrite(STDERR, "Error: " . $e->getMessage() . "\n");
    exit(2);
}
