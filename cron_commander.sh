#!/bin/sh
while [ true ]
do
  git checkout deploy
  gout=$(git pull 2>&1)
  echo $gout
  if ! [[ $gout == "Already up-to-date." ]]
  then
    echo "Changes found, restarting server..."
    ./kill_server.sh
    nohup ./run_server.sh &
  fi
  sleep 60
done
