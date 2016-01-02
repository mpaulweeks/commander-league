#!/bin/sh
while [ true ]
do
  git checkout deploy
  gout=$(git pull 2>&1)
  echo $gout
  # ./server.sh
  sleep 60
done
