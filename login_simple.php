<?php
require_once __DIR__ . '/config/config.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Login - <?php echo SITE_NAME; ?></title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="auth-no-nav">
    <?php include __DIR__ . '/inc/header.php'; ?>

    <main class="auth-page">
        <div class="auth-container">
            <aside class="auth-brand">
                <div class="brand-logo">
                    <img src="images/logo.png" alt="<?php echo SITE_NAME; ?>">
                </div>
                <h1><?php echo SITE_NAME; ?></h1>
                <p class="brand-sub">Welcome back!</p>
            </aside>

            <section class="auth-card">
                <h2>Sign In</h2>
                <?php if (!empty($_SESSION['flash'])): ?>
                    <div class="flash">
                        <?php echo $_SESSION['flash']; unset($_SESSION['flash']); ?>
                    </div>
                <?php endif; ?>

                <form method="post" action="login_simple_action.php" class="form-login" novalidate>
                    <div class="field">
                        <label for="username">Username or Email</label>
                        <div class="input-with-icon">
                            <i class="fas fa-user"></i>
                            <input id="username" name="username" type="text" required autofocus placeholder="Username or email">
                        </div>
                    </div>

                    <div class="field">
                        <label for="password">Password</label>
                        <div class="input-with-icon">
                            <i class="fas fa-lock"></i>
                            <input id="password" name="password" type="password" class="password-field" required placeholder="Enter your password">
                            <button type="button" class="btn-icon toggle-password" aria-label="Show password"><i class="fas fa-eye"></i></button>
                        </div>
                    </div>

                    <div class="auth-actions">
                        <button type="submit" class="btn btn-primary btn-block">Proceed</button>
                        <a href="forgot_password.php" class="forgot-link">Forgot Password?</a>
                    </div>
                </form>

                <p style="margin-top:14px;text-align:center;color:var(--text-light);">Don't have an account? <a href="register_simple.php">Register</a></p>
            </section>
        </div>
    </main>

    <?php include __DIR__ . '/inc/footer.php'; ?>
</body>
</html>
