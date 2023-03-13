<?php
require('MulticraftAPI.php');
$api = new MulticraftAPI('https://ENTER_DOMAIN_NAME/api.php', 'ENDER_USERNAME', 'ENTER_API_KEY');
print_r($api->startServer(ENTER_SERVER_ID));
?>