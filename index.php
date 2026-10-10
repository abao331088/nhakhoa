<?php
require __DIR__ . '/config/db.php';
require __DIR__ . '/config/auth.php';

// Determine routing
$publicPages = ['home', 'login', 'register', 'forgot'];
$protectedPages = ['dashboard', 'patients', 'appointments', 'dentists', 'payments', 'treatments'];
$allowed = array_merge($publicPages, $protectedPages);

$defaultPage = is_logged_in() ? 'dashboard' : 'home';
$page = isset($_GET['page']) ? strtolower($_GET['page']) : $defaultPage;
if (!in_array($page, $allowed, true)) { $page = $defaultPage; }

// Enforce authentication for protected pages
if (in_array($page, $protectedPages, true)) {
  require_login($pdo);
} else {
  // Still refresh activity/auto-login via remember-me for public pages
  ensure_session_active($pdo);
}

$pageTitle = 'Dental Management • ' . ucfirst($page);

include __DIR__ . '/includes/header.php';
include __DIR__ . '/includes/sidebar.php';
?>

<main class="main-content p-4 p-md-5 w-100">
  <div class="container-fluid">
    <?php include __DIR__ . '/pages/' . $page . '.php'; ?>
  </div>
</main>

<?php include __DIR__ . '/includes/footer.php';
