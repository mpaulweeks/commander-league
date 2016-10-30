#!/bin/sh
./shell/kill_server.sh

while [ true ]
do
  git checkout deploy
  gout=$(git pull 2>&1)
  echo $gout
  if ! [[ $gout == *"Already up-to-date." ]]
  then
    echo "Changes found, shutting down server..."
    ./shell/kill_server.sh
    sleep 5
  fi

  ./shell/cron_jobs.sh

  pid=`cat server.pid`
  if [ ${#pid} == 0 ]
  then
    echo "Server is offline, starting back up..."
    sleep 5
    ./shell/background.sh
  fi

  sleep 60
done
