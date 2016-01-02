#!/bin/sh

git checkout deploy
git pull
nohup ./run_server.sh &
nohup ./cron_commander.sh &
