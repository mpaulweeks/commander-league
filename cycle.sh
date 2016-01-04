#!/bin/sh

./kill_cron.sh
./kill_server.sh

git checkout deploy
git pull

nohup ./server.sh &
nohup ./cron_commander.sh &
