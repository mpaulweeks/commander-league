#!/bin/sh
./kill_server.sh
pkill -xf "/bin/sh ./cron_commander.sh"
