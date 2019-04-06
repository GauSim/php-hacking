<body style="text-align:center">
  

<?php

echo '<pre>';
echo "MYSQL_CONTAINER => " . $_ENV['MYSQL_CONTAINER'] . "\n";
echo "MYSQL_ROOT_PASSWORD => " . $_ENV['MYSQL_ROOT_PASSWORD'] . "\n";
echo "MYSQL_DATABASE_NAME => " . $_ENV['MYSQL_DATABASE_NAME'] . "\n";
echo '</pre>';
?>
<h1>
<?php
$servername = $_ENV['MYSQL_CONTAINER'];
$username = "root";
$password = $_ENV['MYSQL_ROOT_PASSWORD'];

// Create connection
$conn = new mysqli($servername, $username, $password);

// Check connection
if ($conn->connect_error) {
    die("DB Connection failed: " . $conn->connect_error);
} 
echo "DB Connected successfully!!";
?>
</h1>

<hr>
<hr>

<?php
  phpinfo();
?>

<hr>

<?php
  echo '<pre>';
  print_r($_SERVER);
  echo '</pre>';
?>


</body>