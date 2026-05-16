Admin tools
===========

create_admin.php
----------------
CLI/web helper to create an initial admin user.

CLI usage:

    php admin/create_admin.php --username=admin --password=admin123 --email=admin@example.com

PowerShell wrapper (Windows/XAMPP):

    .\admin\create_admin.ps1 -Username admin -Password admin123 -Email admin@example.com

Web access (only allowed from localhost):

    http://localhost/izzamawy-pastry-shop/admin/create_admin.php?username=admin&password=admin123&email=admin@example.com&confirm=1

Security notes:
- The web interface only accepts requests from localhost and requires `confirm=1`.
- The CLI requires a PHP CLI binary available in PATH or explicit path.

CSRF and rate limiting
----------------------
- The admin login form now includes a CSRF token and a small delay on failed attempts to slow brute-force attacks.
