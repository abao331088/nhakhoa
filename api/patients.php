<?php
header('Content-Type: application/json');

require_once dirname(__DIR__) . '/config/db.php';

function json_response($data, $code = 200) {
  http_response_code($code);
  echo json_encode($data);
  exit;
}

$action = $_GET['action'] ?? ($_POST['action'] ?? 'list');

try {
  if ($action === 'create' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $first = trim($_POST['first_name'] ?? '');
    $last = trim($_POST['last_name'] ?? '');
    $gender = $_POST['gender'] ?? 'Male';
    if ($first === '' || $last === '') {
      json_response(['success' => false, 'error' => 'First and last name are required.'], 400);
    }
    $stmt = $pdo->prepare("INSERT INTO patients(first_name,last_name,gender,birth_date,phone,email,address)
      VALUES(?,?,?,?,?,?,?)");
    $stmt->execute([
      $first,
      $last,
      $gender,
      $_POST['birth_date'] ?: null,
      trim($_POST['phone'] ?? ''),
      trim($_POST['email'] ?? ''),
      trim($_POST['address'] ?? ''),
    ]);
    $id = (int)$pdo->lastInsertId();
    $q = $pdo->prepare("SELECT * FROM patients WHERE patient_id=?");
    $q->execute([$id]);
    $row = $q->fetch();
    json_response(['success' => true, 'patient' => $row]);
  }

  if ($action === 'list') {
    // Oldest first so newest appears at the bottom of the table
    $rows = $pdo->query("SELECT * FROM patients ORDER BY patient_id ASC LIMIT 100")->fetchAll();
    json_response(['success' => true, 'patients' => $rows]);
  }

  // Fallback unknown action
  json_response(['success' => false, 'error' => 'Unknown action.'], 400);
} catch (Throwable $e) {
  json_response(['success' => false, 'error' => $e->getMessage()], 500);
}
