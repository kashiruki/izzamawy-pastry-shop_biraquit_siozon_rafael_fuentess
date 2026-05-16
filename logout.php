<?php
/**
 * Admin Logout
 */

require_once __DIR__ . '/../config/config.php';

// clear session and redirect using helper
$_SESSION = [];
session_destroy();

redirect(SITE_URL . '/admin/login.php');
exit;
