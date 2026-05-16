<?php
// Legacy compatibility: redirect to canonical admin login at /admin/login.php
require_once __DIR__ . '/../config/config.php';

// If requested explicitly to show the legacy form (for testing), allow via ?show_legacy=1
if (isset($_GET['show_legacy']) && $_GET['show_legacy'] === '1') {
    // include the canonical login page for display
    require __DIR__ . '/login.php';
    exit;
}

redirect(SITE_URL . '/admin/login.php');
exit;
