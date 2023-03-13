<?php
$grab = json_decode(file_get_contents('https://launchermeta.mojang.com/mc/game/version_manifest.json'),True);
$url = ($grab['versions'][0]['url']);
$server = json_decode(file_get_contents($url),True);
$version = $grab['versions'][0]['id'];
$file = $server['downloads']['server']['url'];
echo $file;
?>