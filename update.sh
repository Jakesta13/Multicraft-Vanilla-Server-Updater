#!/bin/bash
## Script is to automate updates for multicraft.
### Settings ###
# Dir
dir="/home/minecraft/multicraft/scripts/"
jarDir="/home/multicraft/servers/server#XYZ/path/to/serverJar"
# Server Jar name, usually just server.jar - but also depends on your Multicraft Setup.
serverJar="server.jar"
# Also add a check to make sure the jar filename has a '.jar' in it, and add it if not.
# mcrcon settings (update this to have the ability to know which server is requesting restart)
# In future Literations I will move from mcrcon! Will use MulticraftAPI, I just wanted to get the script I'm currently using onto GitHub
IP=localhost
PORT=25567
PASS=SecRetForMuLa
date="$(date +%m)"
args="${@}"
# Checking for the force argument to force an update when otherwise wouldn't (Entire month of April to be dead sure they change the bamboozle update)
force="$(echo "${args}" | grep "force")"
# Minecraft Port (I should update this to take port number from argument, so it is more portable)
mcport=25565

### ### Message Settings ### ###
# Tellraw Announcement colour? That's Color in one part of the world.
rawColour="dark_purple"
# Tellraw Announcement Message
rawMessage="Server restart has begun!"
# Kick Message
kickMessage="Server is restarting. If there's a new version you should update your client."

### ###
# Let everyone know there is a update occuring
# THOUGH also I should check if there is actually an update before doing all this, rather to just restart normally instead of being a bit too flashy if it's a normal update.
"${dir}/mcrcon" -H "${IP}" -P "${PORT}" -p "${PASS}" 'tellraw @a {"text":"*** ${rawMessage} ***","color":"'"'${rawColour}'"'"}'
sleep 1
# Stop Server
echo "Stopping server!"
# Get playerlist, then kick everyyone alphabetically.. Why alphabetically? I could do it randomly or even just as the list outputs .. but that isn't any fun is it?
"${dir}/mcrcon" -H "${IP}" -P "${PORT}" -p "${PASS}" "list" | sed -e 's/^.*: //' -e 's/ //g' -e 's/\x1b\[[0-9;]*m//g' | tr ',' '\n' | sort |
while read -r line; do
        line=$(echo "${line}" | sed -e '/Executed .* Command/d')
        if [ -z "${line}" ]; then
                echo "No one to kick!"
                break
        else
                "${dir}/mcrcon" -H "${IP}" -P "${PORT}" -p "${PASS}" "kick ${line} ${kickMessage}"
        fi
done
php "${dir}/stop.php"
echo ""
sleep 5
# We are basically waiting for the server to fully go down before doing anything.
# Could also check the log file, but I prefer this way as syntax and outputs can change. Especially since it's Mojang and standardization is overated of course.
# Waiting should be about 120 seconds, so this should be absolutely sure it is down.
echo "Waiting 120s for ${mcport} to go down!"
failed=0
while [ $failed -ne 1 ]
        do
        nc -z -v "${IP}" "${mcport}" 2> /dev/null
        failed=$?
        counter=$((counter + 1))
        if [ "${counter}" -gt 120 ]; then
                echo "after 120 attempts, port ${mcport} is still up!"
                echo "Requesting manual intervention"
                echo "NOTE: Currently not implemented!"
#				Manual intervention would be for something like sending a message to Discord Server alerting admins.
                manual=1
                break
        fi
sleep 1
done
# To avoid april fools updates, we will automatically not update during the entire month of april until we know what is safe. I SAID NO PRANKS. NOT A SINGLE PRANK.
# To allow updates a 'force' tag is added to the args.
# Also, Yes, I ACTUALLY got bamboozled by mojang so I had to add this LOL.
if [ "${date}" -eq "04" ]; then
	if [ -n "${force}" ]; then
		forced="Update"
	else
		unset forced
	fi
else
	forced="Update"
fi
# If 'Manual" is empty, then this script will start the server normally.
# We will also update the server as long as 'Manual" is empty.
if [ -z "${manual}" ]; then
# Create functions to make it easier to run if needed multiple times.
function runsha1 (){
# SHA1 checksum
	sha1sum -c --status <<< "$(echo "$(php ${dir}/version.php) ${jarDir}/${serverJar}")"
	sha1="$(echo $?)"
}
function jarurl (){
# Jar URL to download
        php "${dir}/latest.php"
}
# Check sha1 output, but check if jar url can be found (Connectivity check)
        checkurl=$(jarurl | grep "${serverJar}")
# if checkurl is not empty, then we are good to proceed.
# We also will not update if the date is within Apil, unless 'force' was added to the arguments.
        if [ -n "${checkurl}" ] && [ "${forced}" = "Update" ]; then
		runsha1
                if [ "${sha1}" -ne 0 ]; then
			echo "${sha1}"
                        echo "SHA1 does not match. Updating"
                        mv "${jarDir}/${serverJar}" "${jarDir}/${serverJar}.old"
                        wget -q -P "${jarDir}" "${checkurl}"
                else
                         echo "SHA1 matches. No update required."
                fi
        fi
        sleep 15
        # Start server
        echo "Starting server"
        echo ""
        echo "(Waited ${counter} ping attempts + 15s)"
		# Starting Server now
        php "${dir}/start.php"
        fi
fi
