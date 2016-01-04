#!/bin/sh

echo "kill existing processes"
./kill_cron.sh
./kill_server.sh

echo "get latest version"
git checkout deploy
git pull

echo "waiting for server to shut down..."
sleep 5

echo "start up"
nohup ./server.sh &
nohup ./cron_commander.sh &
