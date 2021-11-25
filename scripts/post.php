<?php

$json = file_get_contents('php://input') . "\n";
$data = json_decode($json);

$fh = fopen("data/results-" . $data->id  . ".csv", 'a') or die("Error opening file!");
fwrite($fh, $json);
fclose($fh);

echo "Success!";
?>
