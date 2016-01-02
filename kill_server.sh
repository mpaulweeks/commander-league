#!/bin/sh
pid=`cat server.pid`
if [ ${#pid} -gt 0 ]
then
  echo "Trying to kill:" $pid
  sudo kill $pid
  cat /dev/null > server.pid
else
  echo "No PID found."
fi
