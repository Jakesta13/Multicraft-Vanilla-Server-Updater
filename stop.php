<?php
require('MulticraftAPI.php');
$api = new MulticraftAPI('https://ENTER_DOMAIN_NAME/api.php', 'ENTER_USERNAME', 'ENTER_API_KEY');
// Probably shouldn't run the console command, and instead use the multicraft API that calls the STOP event - will change this on next script update.
print_r($api->sendConsoleCommand(ENTER_SERVER_ID,stop));
?>