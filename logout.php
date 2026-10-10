<?php
require __DIR__ . '/config/db.php';
require __DIR__ . '/config/auth.php';

logout_user($pdo);
if (session_status() !== PHP_SESSION_ACTIVE) { session_start(); }
set_flash('success', 'You have been logged out.');
header('Location: index.php?page=login');
exit;
