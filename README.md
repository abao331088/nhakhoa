# Dental Management System (PHP + MySQL)

A lightweight PHP app with a clean dashboard (left sidebar) to register patients and manage appointments, dentists, payments, and treatments.

## Quick Start

1) Create the database and tables
- Open phpMyAdmin → Import → select `schema.sql` and run
- Or CLI:
```bash
mysql -u root -p < schema.sql
```

2) Configure DB connection
- Defaults are XAMPP-friendly: host `127.0.0.1`, db `dental_management_system`, user `root`, password empty
- To change, edit [config/db.php](config/db.php)

3) Run the app
- Start Apache + MySQL in XAMPP
- Visit: http://localhost/Dent_managemnet/

## Structure
- [index.php](index.php): Router + shell layout
- [config/db.php](config/db.php): PDO connection
- [includes/](includes): Shared header/sidebar/footer
- [assets/css/styles.css](assets/css/styles.css): Dark theme UI
- [pages/](pages): Feature pages (dashboard, patients, appointments, dentists, payments, treatments)

## Notes
- Pages support creating and listing recent records using prepared statements
- Authentication now enabled: registration + login (bcrypt), remember-me cookies, session timeout (5 minutes idle)
- Users table stores first/last name, sex, contact info, role, status, profile picture, and remember token

## Optional: Seed Data
Uncomment sample INSERTs in [schema.sql](schema.sql) to quickly add dentists.

## Authentication
- Visit `/index.php?page=register` to create an account (fields: names, sex, username, password, phone, email, profile picture, role, status).
- Sign in at `/index.php?page=login` (supports remember-me). Dashboard/CRUD pages require login; Home/Register/Login remain public.
- Sessions auto-expire after 5 minutes of inactivity. Remember-me extends access for 7 days.
- Sidebar shows the current username and role with a logout button.

### Create an Admin User
Use either phpMyAdmin or this one-time PHP helper to insert an admin with a hashed password.

1) Quick PHP helper (delete after use):

Create `scripts/seed_admin.php` with:

```php
<?php
require __DIR__ . '/../config/db.php';
$username = 'admin';
$password = 'admin123';
$hash = password_hash($password, PASSWORD_BCRYPT);
$role = 'Admin';
$stmt = $pdo->prepare('SELECT user_id FROM users WHERE username=?');
$stmt->execute([$username]);
if ($stmt->fetch()) {
	echo "User already exists";
} else {
	$ins = $pdo->prepare('INSERT INTO users(username,password,role) VALUES(?,?,?)');
	$ins->execute([$username, $hash, $role]);
	echo "Admin user created";
}
```

Run it once:

http://localhost/Dent_managemnet/scripts/seed_admin.php

Then delete `scripts/seed_admin.php`.

2) Via SQL (if you have a hash):

```sql
INSERT INTO users(username,password,role)
VALUES ('admin', '$2y$10$replaceWithYourHashHere', 'Admin');
```
