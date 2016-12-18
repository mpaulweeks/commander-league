#!/bin/sh
git checkout deploy
gout=$(git pull 2>&1)
echo $gout
if ! [[ $gout == *"Already up-to-date." ]]
then
  echo "Changes found, shutting down server..."
  ./bash/kill_server.sh
  sleep 5
fi

pid=`cat server.pid`
if [ ${#pid} == 0 ]
then
  echo "Server is offline, starting back up..."
  sleep 5
  ./bash/bg_commander.sh
fi
