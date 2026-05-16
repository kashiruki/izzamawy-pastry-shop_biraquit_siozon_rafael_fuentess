<?php
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/database.php';
if (!is_admin_logged_in()) redirect(SITE_URL . '/admin/admin_login.php');
$db = Database::getInstance()->getConnection();
$id = (int)($_GET['id'] ?? 0);
$order = null;
$items = [];
if ($id) {
    try {
        $stmt = $db->prepare('SELECT * FROM orders WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $order = $stmt->fetch(PDO::FETCH_ASSOC);
        try {
            $it = $db->prepare('SELECT * FROM order_items WHERE order_id = :id');
            $it->execute([':id' => $id]);
            $items = $it->fetchAll(PDO::FETCH_ASSOC);
        } catch (Throwable $e) { $items = []; }
    } catch (Throwable $e) { $order = null; }
}
?>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Order Details - <?php echo SITE_NAME; ?></title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body style="padding:24px;font-family:Segoe UI, Tahoma, sans-serif;background:#f8f7f5">
    <a href="dashboard.php">← Back to dashboard</a>
    <div style="max-width:980px;margin-top:14px;background:#fff;padding:18px;border-radius:10px;box-shadow:0 8px 26px rgba(0,0,0,0.06)">
        <?php if (!$order): ?>
            <h2>Order not found</h2>
            <p>No order matches that ID.</p>
        <?php else: ?>
            <h2>Order <?php echo htmlspecialchars($order['order_number'] ?? $order['id']); ?></h2>
            <p style="color:#666">Customer: <?php echo htmlspecialchars($order['customer_name'] ?? ''); ?> · Date: <?php echo htmlspecialchars($order['created_at'] ?? ''); ?></p>
            <h3>Items</h3>
            <table style="width:100%;border-collapse:collapse">
                <thead><tr style="text-align:left"><th>Product</th><th>Qty</th><th>Price</th><th>Subtotal</th></tr></thead>
                <tbody>
                <?php foreach ($items as $it): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($it['product_name'] ?? $it['product_id'] ?? ''); ?></td>
                        <td><?php echo (int)($it['quantity'] ?? 0); ?></td>
                        <td><?php echo format_price($it['price'] ?? 0); ?></td>
                        <td><?php echo format_price((($it['price'] ?? 0) * ($it['quantity'] ?? 0))); ?></td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            <div style="margin-top:12px;text-align:right;font-weight:800">Total: <?php echo format_price($order['total'] ?? 0); ?></div>
        <?php endif; ?>
    </div>
</body>
</html>
